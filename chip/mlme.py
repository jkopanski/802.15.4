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
