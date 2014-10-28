"""MAC sublayer management entity module
"""

class associate:
    class request:
        """MLME-ASSOCIATE.request primitive is used by a device to request an association with a coordinator.
        """
        def __init__( self,
                      ChannelNumber,
                      ChannelPage,
                      CoordAddrMode,
                      CoordPANId,
                      CoordAddress,
                      CapabilityInformation,
                      SecurityLevel,
                      KeyIdMode,
                      KeySource,
                      KeyIndex):
            pass
            
class reset:
    """MLME-RESET
    
    Mac sublayer management entity reset primitive
    """
    class request:
        def __init__( self, SetDefaultPIB):
            self.SetDefaultPIB = SetDefaultPIB
            
    class confirm:
        def __init__( self, status):
            self.status = status

class scan:
    """MLME-SCAN"""
    class request:
        def __init__( self,
                      ScanType,
                      ScanChannels,
                      ScanDuration,
                      ChannelPage,
                      SecurityLevel,
                      KeyIdMode,
                      KeySource,
                      KeyIndex):
            self.ScanType      = ScanType
            self.ScanChannels  = ScanChannels
            self.ScanDuration  = ScanDuration
            self.ChannelPage   = ChannelPage
            self.SecurityLevel = SecurityLevel
            self.KeyIdMode     = KeySource
            self.KeyIndex      = KeyIndex

class set:
    """MLME-SET"""
    class request:
        def __init__( self,
                      PIBAttribute,
                      PIBAttributeValue):
            self.PIBAttribute      = PIBAttribute
            self.PIBAttributeValue = PIBAttributeValue

    class confirm:
        def __init__( self,
                      status,
                      PIBAttribute):
            self.status       = status
            self.PIBAttribute = PIBAttribute
            
