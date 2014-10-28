import logging
import random
import math
from enum import Enum

import chip.phy
import chip.mlme as mlme
import chip.mcps as mcps
from chip.phy import constants as phyConst

class status( Enum):
    SUCCESS              =  1
    INVALID_PARAMETER    =  0
    FAILURE              =  0

    LIMIT_REACHED        =  0
    NO_BEACON            = -1
    SCAN_IN_PROGRESS     = -2
    COUNTER_ERROR        = -3
    FRAME_TOO_LONG       = -4
    UNAVAILABLE_KEY      = -5
    UNSUPPORTED_SECURITY = -6

    """MLME-SET.confirm status"""
    READ_ONLY             =  0
    UNSUPPORTED_ATTRIBUTE = -1
    INVALID_INDEX         = -2


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
        
        self.pib = pib( ackWaitDuration,
                        6, # FIXME: calculate actual value
                        maxFrameTotalWaitTime,
                        0, # FIXME: calculate actual value
                        0, # FIXME: calculate actual value
                        0, # FIXME: calculate actual value
                        2000, # FIXME: calculate based on selected PHY
                        2000) # FIXME: calculate based on selected PHY
            
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
            if   primitive.PIBAttribute == "macExtendedAddress":
                res = status.READ_ONLY
                return mlme.set.confirm( status, primitive.PIBAttribute)
            elif primitive.PIBAttribute == "macAckWaitDuration":
                res = status.READ_ONLY
            elif primitive.PIBAttribute == "macAssociatedPANCoord":
                if primitive.PIBAttributeValue == True or False:
                    setattr( self.pib, primitive.PIBAttribute, primitive.PIBAttributeValue)
                    res = status.SUCCESS
                else:
                    res = status.INVALID_PARAMETER
            else:
                res = status.UNSUPPORTED_ATTRIBUTE
            return mlme.set.confirm( res, primitive.PIBAttribute)
                    
                    
        elif isinstance( primitive, mcps):
            pass
        else:
            raise BaseException
