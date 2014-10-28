import logging
from enum import Enum, unique

class enum( Enum):
    dB_1 = 1
    dB_3 = 3
    dB_6 = 6

class constants:
    """PHY layer constants
    """
    aMaxPHYPacketSize = 127
    aTurnaroundTime   = 12


@unique
class phyType( Enum):
    """Enumeration defining phy type
    """
    OQPSK = 0
    BPSK  = 1
    ASK   = 2
    CSS   = 3
    UWB   = 4
    MPSK  = 5
    GFSK  = 6


class pib:
    """PHY Personal Area Network Information Base
    """
    def __init__( self,
                  phyCurrentChannel,
                  phyChannelsSupported,
                  phyTXPowerTolerance,
                  phyTXPower,
                  phyCCAMode ,
                  phyCurrentPage,
                  # phyMaxFrameDuration = ,
                  # phySHRDuration = ,
                  # phySymbolsPerOctet = ,
                  # phyPreambleSymbolLength = ,
                  # phyUWBDataRatesSupported = ,
                  # phyCSSLowDataRateSupported = ,
                  # phyUWBCoUSupported = ,
                  # phyUWBCSSupported = ,
                  # phyUWBLCPSupported = ,
                  # phyUWBCurrentPulseShape = ,
                  # phyUWBCoUpulse = ,
                  # phyUWBCSpulse = ,
                  # phyUWBLCPWeight1 = ,
                  # phyUWBLCPWeight2 = ,
                  # phyUWBLCPWeight3 = ,
                  # phyUWBLCPWeight4 = ,
                  # phyUWBLCPDelay2 = ,
                  # phyUWBLCPDelay3 = ,
                  # phyUWBLCPDelay4 = ,
                  # phyRanging = ,
                  # phyRangingCrystalOffset = ,
                  # phyRangingDPS = ,
                  # phyCurrentCode = ,
                  # phyNativePRF = ,
                  # phyUWBScanBinsPerChannel = ,
                  # phyUWBInsertedPreambleInterval = ,
                  # phyTXRMARKEROffset = ,
                  # phyRXRMARKEROffset = ,
                  # phyRFRAMEProcessingTime = ,
                  # phyCCADuration = ,):
                  ):
        self.phyCurrentChannel              = phyCurrentChannel
        self.phyChannelsSupported           = phyChannelsSupported
        self.phyTXPowerTolerance            = phyTXPowerTolerance
        self.phyTXPower                     = phyTXPower
        self.phyCCAMode                     = phyCCAMode
        self.phyCurrentPage                 = phyCurrentPage
        # self.phyMaxFrameDuration            = phyMaxFrameDuration
        # self.phySHRDuration                 = phySHRDuration
        # self.phySymbolsPerOctet             = phySymbolsPerOctet
        # self.phyPreambleSymbolLength        = phyPreambleSymbolLength
        # self.phyUWBDataRatesSupported       = phyUWBDataRatesSupported
        # self.phyCSSLowDataRateSupported     = phyCSSLowDataRateSupported
        # self.phyUWBCoUSupported             = phyUWBCoUSupported
        # self.phyUWBCSSupported              = phyUWBCSSupported
        # self.phyUWBLCPSupported             = phyUWBLCPSupported
        # self.phyUWBCurrentPulseShape        = phyUWBCurrentPulseShape
        # self.phyUWBCoUpulse                 = phyUWBCoUpulse
        # self.phyUWBCSpulse                  = phyUWBCSpulse
        # self.phyUWBLCPWeight1               = phyUWBLCPWeight1
        # self.phyUWBLCPWeight2               = phyUWBLCPWeight2
        # self.phyUWBLCPWeight3               = phyUWBLCPWeight3
        # self.phyUWBLCPWeight4               = phyUWBLCPWeight4
        # self.phyUWBLCPDelay2                = phyUWBLCPDelay2
        # self.phyUWBLCPDelay3                = phyUWBLCPDelay3
        # self.phyUWBLCPDelay4                = phyUWBLCPDelay4
        # self.phyRanging                     = phyRanging
        # self.phyRangingCrystalOffset        = phyRangingCrystalOffset
        # self.phyRangingDPS                  = phyRangingDPS
        # self.phyCurrentCode                 = phyCurrentCode
        # self.phyNativePRF                   = phyNativePRF
        # self.phyUWBScanBinsPerChannel       = phyUWBScanBinsPerChannel
        # self.phyUWBInsertedPreambleInterval = phyUWBInsertedPreambleInterval
        # self.phyTXRMARKEROffset             = phyTXRMARKEROffset
        # self.phyRXRMARKEROffset             = phyRXRMARKEROffset
        # self.phyRFRAMEProcessingTime        = phyRFRAMEProcessingTime
        # self.phyCCADuration                 = phyCCADuration
        
        
class Phy:
    def __init__( self, phy):
        if   phy == phyType.OQPSK:
            self.pib = pib( phyCurrentChannel    = 0,
                            # TODO: create list
                            phyChannelsSupported = 0,
                            phyTXPowerTolerance  = enum.dB_1,
                            phyTXPower           = 0,
                            phyCCAMode           = 1,
                            phyCurrentPage       = 0)
                            # phyMaxFrameDuration  = ,
                            # phySHRDuration = ,
                            # phySymbolsPerOctet = ,
                            # phyPreambleSymbolLength = ,
                            # phyUWBDataRatesSupported = ,
                            # phyCSSLowDataRateSupported = ,
                            # phyUWBCoUSupported = ,
                            # phyUWBCSSupported = ,
                            # phyUWBLCPSupported = ,
                            # phyUWBCurrentPulseShape = ,
                            # phyUWBCoUpulse = ,
                            # phyUWBCSpulse = ,
                            # phyUWBLCPWeight1 = ,
                            # phyUWBLCPWeight2 = ,
                            # phyUWBLCPWeight3 = ,
                            # phyUWBLCPWeight4 = ,
                            # phyUWBLCPDelay2 = ,
                            # phyUWBLCPDelay3 = ,
                            # phyUWBLCPDelay4 = ,
                            # phyRanging = ,
                            # phyRangingCrystalOffset = ,
                            # phyRangingDPS = ,
                            # phyCurrentCode = ,
                            # phyNativePRF = ,
                            # phyUWBScanBinsPerChannel = ,
                            # phyUWBInsertedPreambleInterval = ,
                            # phyTXRMARKEROffset = ,
                            # phyRXRMARKEROffset = ,
                            # phyRFRAMEProcessingTime = ,
                            # phyCCADuration = )
        elif phy == phyType.BPSK:
            pass
        elif phy == phyType.ASK:
            pass
        elif phy == phyType.CSS:
            pass
        elif phy == phyType.UWB:
            pass
        elif phy == phyType.MPSK:
            pass
        elif phy == phyType.GFSK:
            pass
        else:
            raise BaseException
