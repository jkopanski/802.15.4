import logging
from enum import Enum

import chip.mlme as mlme
import chip.mcps as mcps
from chip.phy import constants as phyConst

class enum( Enum):
    FAILURE = 0
    SUCCESS = 1

class constants( Enum):
    """MAC layer constants
    """
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

    aBaseSuperframeDuration   = aBaseSlotDuration * aNumSuperframeSlots
    aMaxBeaconPayloadLength   = phyConst.aMaxPHYPacketSize - aMaxBeaconOverhead
    aMaxMACSafePayloadSize    = phyConst.aMaxPHYPacketSize - aMaxMPDUUnsecuredOverhead
    aMaxMACPayloadSize        = phyConst.aMaxPHYPacketSize - aMinMPDUOverhead
    

class pib:
    """MAC Personal Area Network Information Base
    """
    def __init__( self,
                  macExtendedAddress            = 0,
                  # macAckWaitDuration            = aUnitBackoffPeriod + aTurnaroundTime + phySHRDuration + ceil( 6 * phySymbolsPerOctet),
                  macAssociatedPANCoord         = False,
                  macAssociationPermit          = False,
                  macAutoRequest                = True,
                  macBattLifeExt                = False,
                  # macBattLifeExtPeriods         = ,
                  macBeaconPayload              = None,
                  macBeaconPayloadLength        = 0,
                  macBeaconOrder                = 15,
                  macBeaconTxTime               = 0,
                  # macBSN                        = ,
                  # macCoordExtendedAddress       = ,
                  macCoordShortAddress          = int( '0xffff', 16),
                  # macDSN                        = ,
                  macGTSPermit                  = True,
                  macMaxBE                      = 5,
                  macMaxCSMABackoffs            = 4,
                  # macMaxFrameTotalWaitTime      = ,
                  macMaxFrameRetries            = 3,
                  macMinBE                      = 3,
                  # macLIFSPeriod                 = ,
                  # macSIFSPeriod                 = ,
                  macPANId                      = int( '0xffff', 16),
                  macPromiscuousMode            = False,
                  macRangingSupported           = False,
                  macResponseWaitTime           = 32,
                  macRxOnWhenIdle               = False,
                  macSecurityEnabled            = False,
                  macShortAddress               = int( '0xffff', 16),
                  macSuperframeOrder            = 15,
                  # macSyncSymbolOffset           = ,
                  # macTimestampSupported         = ,
                  # macTransactionPersistenceTime = ,
                  # macTxControlActiveDuration    = ,
                  # macTxControlPauseDuration     = ,
                  macTxTotalDuration            = 0):
        self.macExtendedAddress            = macExtendedAddress
        # self.macAckWaitDuration            = macAckWaitDuration
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
        return
            
    def request( self, primitive):
        pass

    def command( self, primitive):
        if   isinstance( primitive, mlme.reset.request):
            logging.debug( "MAC received: MLME-RESET.request")
            if primitive.SetDefaultPIB:
                logging.debug( "MAC resseting to default PIB")
            else:
                logging.debug( "MAC reseting with preserved PIB")
            
            # Wait for reset complete
            return mlme.reset.confirm( enum.SUCCESS)

        elif isinstance( prmitive, mlme.reset.confirm):
            logging.debug( "MAC received: MLME-RESET.confirm")
        elif isinstance( primitive, mcps):
            pass
        else:
            raise BaseException
