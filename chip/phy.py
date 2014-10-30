import logging
import math
from enum import Enum, unique


class PhyFreqError( Exception):
    pass


class constants:
    """PHY layer constants"""
    aMaxPHYPacketSize = 127
    aTurnaroundTime   = 12


class powerTolerance( Enum):
    """phyTXPowerTolerance valid entries"""
    dB_1 = 1
    dB_3 = 3
    dB_6 = 6


class pulseShape( Enum):
    """phyUWBCurrentPulseShape valid entries"""
    MANDATORY = 0
    COU       = 1
    CS        = 2
    LCP       = 4


class couPulse( Enum):
    """phyUWBCoUpulse valid entries"""
    CCh_1 = 1
    CCh_2 = 2
    CCh_3 = 3
    CCh_4 = 4
    CCh_5 = 5
    CCh_6 = 6


class csPulse( Enum):
    """phyUWBCSpulse valid entries"""
    No_1 = 1
    No_2 = 2
    No_3 = 3
    No_4 = 4
    No_5 = 5
    No_6 = 6


class band( Enum):
    """Enumeration defining valid frequency bands"""
    MHz_780  = 0
    MHz_868  = 1
    MHz_915  = 1
    MHz_950  = 2
    MHz_2450 = 3
    UWB_SUB  = 4
    UWB_LOW  = 5
    UWB_HI   = 6


@unique
class phyType( Enum):
    """Enumeration defining phy type"""
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
                  phyMaxFrameDuration,
                  phySHRDuration,
                  phySymbolsPerOctet
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
        self.phyMaxFrameDuration            = phyMaxFrameDuration
        self.phySHRDuration                 = phySHRDuration
        self.phySymbolsPerOctet             = phySymbolsPerOctet
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
    def __init__( self, freq):
        self.pib = { # key: value
            'phyCurrentChannel':   None,
            'phyChannelsSupportd': None,
            'phyCurrentPage':      None
        }
        logging.debug( '{0} created using {1}'.format( repr( self), repr( freq)))


class OQPSKPhy( Phy):
    def __init__( self, freq):
        if   freq == band.MHz_780:
            self.pib['phyChannelsSupported'] = [5]
        elif freq == band.MHz_868 or \
             freq == band.MHz_915 or \
             freq == band.MHz_2450:
            self.pib['phyChannelsSupported'] = [0, 1, 2]
        else:
            raise PhyFreqError( '{0} is not valid for {1}'
                                .format( repr( freq), repr(self)))


class BPSKPhy( Phy):
    def __init__( self, freq):
        if   freq == band.MHz_868 or \
             freq == band.MHz_915:
            self.pib['phyChannelsSupported'] = [0, 1, 2]
        elif freq == band.MHz_950:
            self.pib['phyChannelsSupported'] = [6]
        else:
            raise PhyFreqError( '{0} is not valid for {1}'
                                .format( repr( freq), repr(self)))


class ASKPhy( Phy):
    def __init__( self, freq):
        if   freq == band.MHz_868 or \
             freq == band.MHz_915:
            self.pib['phyChannelsSupported'] = [0, 1, 2]
        else:
            raise PhyFreqError( '{0} is not valid for {1}'
                                .format( repr( freq), repr(self)))
