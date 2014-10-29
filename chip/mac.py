import logging
import numbers
import random
import math
from enum import Enum

import chip.phy
import chip.mlme as mlme
import chip.mcps as mcps
from chip.phy import constants as phyConst

class status( Enum):
    SUCCESS              =  1
    FAILURE              =  0
    INVALID_PARAMETER    = -1

    """MLME-SET.confirm status"""
    READ_ONLY             = -2
    UNSUPPORTED_ATTRIBUTE = -3
    INVALID_INDEX         = -4

    LIMIT_REACHED         = -5
    NO_BEACON             = -6
    SCAN_IN_PROGRESS      = -7
    COUNTER_ERROR         = -8
    FRAME_TOO_LONG        = -9
    UNAVAILABLE_KEY       = -10
    UNSUPPORTED_SECURITY  = -11


class scanType( Enum):
    ED      = 0
    ACTIVE  = 1
    PASSIVE = 2
    ORPHAN  = 3

class constants:
    """MAC layer constants"""
    aBaseSlotDuration         = 60
    aGTSDescPersistenceTime   = 4
    aMaxBeaconOverhead        = 75
    aMaxLostBeacons           = 4
    aMaxMPDUUnsecuredOverhead = 25
    aMaxSIFSFrameSize         = 18
    aMinCAPLength             = 440
    aMinMPDUOverhead          = 9
    aNumSuperframeSlots       = 16
    aUnitBackoffPeriod        = 20
    # constants derived from previous consts
    aBaseSuperframeDuration   = aBaseSlotDuration * aNumSuperframeSlots
    aMaxBeaconPayloadLength   = phyConst.aMaxPHYPacketSize - aMaxBeaconOverhead
    aMaxMACSafePayloadSize    = phyConst.aMaxPHYPacketSize - aMaxMPDUUnsecuredOverhead
    aMaxMACPayloadSize        = phyConst.aMaxPHYPacketSize - aMinMPDUOverhead
    

class pib:
    """MAC Personal Area Network Information Base"""
    def __init__( self,
                  macAckWaitDuration,
                  macBattLifeExtPeriods,
                  macMaxFrameTotalWaitTime,
                  macLIFSPeriod,
                  macSIFSPeriod,
                  macSyncSymbolOffset,
                  macTxControlActiveDuration,
                  macTxControlPauseDuration,
                  macExtendedAddress            = 0,
                  macAssociatedPANCoord         = False,
                  macAssociationPermit          = False,
                  macAutoRequest                = True,
                  macBattLifeExt                = False,
                  macBeaconPayload              = None,
                  macBeaconPayloadLength        = 0,
                  macBeaconOrder                = 15,
                  macBeaconTxTime               = 0,
                  macBSN                        = random.randrange( int( '0xff', 16)),
                  macCoordExtendedAddress       = None,
                  macCoordShortAddress          = int( '0xffff', 16),
                  macDSN                        = random.randrange( int( '0xff', 16)),
                  macGTSPermit                  = True,
                  macMaxBE                      = 5,
                  macMaxCSMABackoffs            = 4,
                  macMaxFrameRetries            = 3,
                  macMinBE                      = 3,
                  macPANId                      = int( '0xffff', 16),
                  macPromiscuousMode            = False,
                  macRangingSupported           = False,
                  macResponseWaitTime           = 32,
                  macRxOnWhenIdle               = False,
                  macSecurityEnabled            = False,
                  macShortAddress               = int( '0xffff', 16),
                  macSuperframeOrder            = 15,
                  macTimestampSupported         = False,
                  macTransactionPersistenceTime = int( '0x01f4', 16),
                  macTxTotalDuration            = 0):
        self.macExtendedAddress            = macExtendedAddress
        self.macAckWaitDuration            = macAckWaitDuration
        self.macAssociatedPANCoord         = macAssociatedPANCoord
        self.macAssociationPermit          = macAssociationPermit
        self.macAutoRequest                = macAutoRequest
        self.macBattLifeExt                = macBattLifeExt
        self.macBattLifeExtPeriods         = macBattLifeExtPeriods
        self.macBeaconPayload              = macBeaconPayload
        self.macBeaconPayloadLength        = macBeaconPayloadLength
        self.macBeaconOrder                = macBeaconOrder
        self.macBeaconTxTime               = macBeaconTxTime
        self.macBSN                        = macBSN
        self.macCoordExtendedAddress       = macCoordExtendedAddress
        self.macCoordShortAddress          = macCoordShortAddress
        self.macDSN                        = macDSN
        self.macGTSPermit                  = macGTSPermit
        self.macMaxBE                      = macMaxBE
        self.macMaxCSMABackoffs            = macMaxCSMABackoffs
        self.macMaxFrameTotalWaitTime      = macMaxFrameTotalWaitTime
        self.macMaxFrameRetries            = macMaxFrameRetries
        self.macMinBE                      = macMinBE
        self.macLIFSPeriod                 = macLIFSPeriod
        self.macSIFSPeriod                 = macSIFSPeriod
        self.macPANId                      = macPANId
        self.macPromiscuousMode            = macPromiscuousMode
        self.macRangingSupported           = macRangingSupported
        self.macResponseWaitTime           = macResponseWaitTime
        self.macRxOnWhenIdle               = macRxOnWhenIdle
        self.macSecurityEnabled            = macSecurityEnabled
        self.macShortAddress               = macShortAddress
        self.macSuperframeOrder            = macSuperframeOrder
        self.macSyncSymbolOffset           = macSyncSymbolOffset
        self.macTimestampSupported         = macTimestampSupported
        self.macTransactionPersistenceTime = macTransactionPersistenceTime
        self.macTxControlActiveDuration    = macTxControlActiveDuration
        self.macTxControlPauseDuration     = macTxControlPauseDuration
        self.macTxTotalDuration            = macTxTotalDuration
        

class Mac:
    def __init__( self, phy):
        self.phy = phy
        ackWaitDuration = constants.aUnitBackoffPeriod + \
                          phyConst.aTurnaroundTime + \
                          self.phy.pib.phySHRDuration + \
                          math.ceil( 6 * self.phy.pib.phySymbolsPerOctet)
        # calculate default value, based on defaluts
        # proper formulas are in comments
        # m = min( macMaxBE - macMinBE, macMaxCSMABackoffs)
        m = min( 5 - 3, 4)
        sum = 0
        for k in range( m):
            # sum += 2 ** ( macMinBE + k)
            sum += 2 ** ( 3 + k)
        # maxFrameTotalWaitTime = ( sum + \
        #                           ( ( 2 ** macMinBE - 1) * \
        #                             ( macMaxCSMABackoffs - m))) * constants.aUnitBackoffPeriod + self.phy.pib.phyMaxFrameDuration
        maxFrameTotalWaitTime = ( sum + \
                                  ( ( 2 ** 3 - 1) * \
                                    ( 4 - m))) * constants.aUnitBackoffPeriod + self.phy.pib.phyMaxFrameDuration
        
        if self.phy.kind == chip.phy.phyType.UWB:
            raise BaseExeption

        self._setDefaultPIB()

    def _setDefaultPIB( self):
        self.pib = { # key: [ value, lower, upper]
            'macExtendedAddress':           [ None, int( '0x0000000000000001', 16), int( '0xfffffffffffffffe', 16)],
            'macAckWaitDuration':           [ None, 0, 0],
            'macAssociatedPANCoord':        [ False, False, True],
            'macAssociationPermit':         [ False, False, True],
            'macAutoRequest':               [ True, False, True],
            'macBattLifeExt':               [ False, False, True],
            'macBattLifeExtPeriods':        [ None, 6, 41],
            'macBeaconPayload':             [ None, 0, 2 ** ( 8 * constants.aMaxBeaconPayloadLength)],
            'macBeaconPayloadLength':       [ 0, 0, constants.aMaxBeaconPayloadLength],
            'macBeaconOrder':               [ 15, 0, 15],
            'macBeaconTxTime':              [ int( '0x000000', 16), int( '0x000000', 16), int( '0xffffff', 16)],
            'macBSN':                       [ random.randint( 0, int( '0xff', 16) + 1), int( '0x00', 16), int( '0xff', 16)], 
            'macCoordExtendedAddress':      [ None, int( '0x0000000000000001', 16), int( '0xfffffffffffffffe', 16)],
            'macCoordShortAddress':         [ int( '0xffff', 16), int( '0x0000', 16), int( '0xffff', 16)],
            'macDSN':                       [ random.randint( 0, int( '0xff', 16) + 1), int( '0x00', 16), int( '0xff', 16)],
            'macGTSPermit':                 [ True, False, True],
            'macMaxBE':                     [ 5, 3, 8],
            'macMaxCSMABackoffs':           [ 4, 0, 5],
            'macMaxFrameTotalWaitTime':     [ None, None, None],
            'macMaxFrameRetries':           [ 3, 0, 7],
            'macMinBE':                     [ 3, 0, 5],
            'macLIFSPeriod':                [ None, None, None],
            'macSIFSPeriod':                [ None, None, None],
            'macPANId':                     [ int( '0xffff', 16), int( '0x0000', 16), int( '0xffff', 16)],
            'macPromiscuousMode':           [ False, False, True],
            'macRangingSupported':          [ False, False, True],
            'macResponseWaitTime':          [ 32, 2, 64],
            'macRxOnWhenIdle':              [ False, False, True],
            'macSecurityEnabled':           [ False, False, True],
            'macShortAddress':              [ int( '0xffff', 16), int( '0x0000', 16), int( '0xffff', 16)],
            'macSuperframeOrder':           [ 15, 0, 15],
            'macSyncSymbolOffset':          [ None, None, None],
            'macTimestampSupported':        [ False, False, True],
            'macTransactionPersistenceTime':[ int( '0x01f4', 16), int( '0x0000', 16), int( '0xffff', 16)],
            'macTxControlActiveDuration':   [ None, 0, 100000],
            'macTxControlPauseDuration':    [ None, 0, 100000],
            'macTxTotalDuration':           [ 0, int( '0x0', 16), int( '0xffffffff', 16)]
        }

    def _set_pib_attr( self, attribute, value):
        if self.pib[attribute][1] <= value <= self.pib[attribute][2]:
            self.pib[attribute][0] = value
            return status.SUCCESS
        else:
            return status.INVALID_PARAMETER

    def command( self, primitive):
        if   isinstance( primitive, mlme.reset.request):
            logging.debug( "MAC received: MLME-RESET.request")
            if primitive.SetDefaultPIB:
                logging.debug( "MAC resseting to default PIB")
            else:
                logging.debug( "MAC reseting with preserved PIB")
            
            # Wait for reset complete
            return mlme.reset.confirm( status.SUCCESS)

        elif isinstance( primitive, mlme.set.request):
            logging.debug( 'MAC received: MLME-SET.request( {0}, {1})'.format( primitive.PIBAttribute, primitive.PIBAttributeValue))

            # check if attribute exists
            if primitive.PIBAttribute not in self.pib:
                return mlme.set.confirm( status.UNSUPPORTED_ATTRIBUTE, primitive.PIBAttribute)

            # check if attribute is read only
            if primitive.PIBAttribute in ["macExtendedAddress",
                                          "macCoordExtendedAddress",
                                          "macMaxFrameTotalWaitTime",
                                          "macLIFSPeriod",
                                          "macSIFSPeriod",
                                          "macRangingSupported",
                                          "macTimestampSupported"]:
                return mlme.set.confirm( status.READ_ONLY, primitive.PIBAttribute)
            
            return mlme.set.confirm( self._set_pib_attr( primitive.PIBAttribute,
                                                         primitive.PIBAttributeValue),
                                     primitive.PIBAttribute)

            # elif primitive.PIBAttribute == "macAckWaitDuration":
            #     res = status.READ_ONLY

            # elif primitive.PIBAttribute == "macAssociatedPANCoord":
            #     if primitive.PIBAttributeValue == True or False:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macAssociationPermit":
            #     if primitive.PIBAttributeValue == True or False:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macAutoRequest":
            #     if primitive.PIBAttributeValue == True or False:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macBattLifeExt":
            #     if primitive.PIBAttributeValue == True or \
            #        primitive.PIBAttributeValue == False:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macBattLifeExtPeriods":
            #     self._set_pib_integer( primitive.PIBAttribute,
            #                            primitive.PIBAttributeValue,
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 6 <= primitive.PIBAttributeValue <= 41:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macBeaconPayload":
            #     setattr( self.pib,
            #              primitive.PIBAttribute,
            #              primitive.PIBAttributeValue)
            #     res = status.SUCCESS

            # elif primitive.PIBAttribute == "macBeaconPayloadLength":
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 0 <= primitive.PIBAttributeValue <= constants.aMaxBeaconPayloadLength:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macBeaconOrder":
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 0 <= primitive.PIBAttributeValue <= 15:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macBeaconTxTime":
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 0 <= primitive.PIBAttributeValue <= int( '0xffffff', 16):
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macBSN":
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 0 <= primitive.PIBAttributeValue <= int( '0xff', 16):
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER
            
            # elif primitive.PIBAttribute == "macCoordExtendedAddress":
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 0 < primitive.PIBAttributeValue < int( '0xffffffffffffffff', 16):
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macCoordShortAddress":
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 0 <= primitive.PIBAttributeValue <= int( '0xffff', 16):
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macDSN":
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 0 <= primitive.PIBAttributeValue <= int( '0xff', 16):
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macGTSPermit":
            #     if primitive.PIBAttributeValue == True or \
            #        primitive.PIBAttributeValue == False:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macMaxBE":
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 3 <= primitive.PIBAttributeValue <= 5:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macMaxCSMABackoffs":
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 0 <= primitive.PIBAttributeValue <= 5:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macMaxFrameTotalWaitTime":
            #     # FIXME: calculate range
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 0 <= primitive.PIBAttributeValue <= 5:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macMaxFrameRetries":
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 0 <= primitive.PIBAttributeValue <= 7:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macMinBE":
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 0 <= primitive.PIBAttributeValue <= self.pib.macMaxBE:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macLIFSPeriod":
            #     # FIXME: calculate range
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 0 <= primitive.PIBAttributeValue <= 5:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # elif primitive.PIBAttribute == "macSIFSPeriod":
            #     # FIXME: calculate range
            #     if isinstance( primitive.PIBAttributeValue, numbers.Integral) and 0 <= primitive.PIBAttributeValue <= 5:
            #         setattr( self.pib,
            #                  primitive.PIBAttribute,
            #                  primitive.PIBAttributeValue)
            #         res = status.SUCCESS
            #     else:
            #         res = status.INVALID_PARAMETER

            # else:
            #     res = status.UNSUPPORTED_ATTRIBUTE

            # return mlme.set.confirm( res, primitive.PIBAttribute)
                    
                    
        elif isinstance( primitive, mcps):
            pass
        else:
            raise BaseException
