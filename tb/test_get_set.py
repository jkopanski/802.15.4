import unittest
import logging
import random
import math
import chip.mac
import chip.phy
import chip.mlme as mlme

class TestGetSet( unittest.TestCase):
    def setUp( self):
        logging.basicConfig( format   = '%(asctime)s %(message)s', \
                             filename = 'test_get_set.log', \
                             filrmode = 'w+', \
                             level    = logging.DEBUG)
        self.phy = chip.phy.Phy( chip.phy.phyType.OQPSK)
        self.dut = chip.mac.Mac( self.phy)

    def set_param( self, param, lower, upper):
        val        = random.randint( lower - 100, math.ceil( 1.5 * upper))
        set_result = self.dut.command( mlme.set.request( param, val))
        self.assertTrue( isinstance( set_result, mlme.set.confirm))
        # perform MLME-GET as well
        get_result = self.dut.command( mlme.get.request( param))
        self.assertTrue( isinstance( get_result, mlme.get.confirm))
        
        if lower <= val <= upper:
            self.assertEqual( set_result.status, chip.mac.status.SUCCESS)
            self.assertEqual( set_result.status, get_result.status)
        else:
            self.assertEqual( set_result.status, chip.mac.status.INVALID_PARAMETER)
            self.assertEqual( self.dut.pib[get_result.PIBAttribute][0],
                              get_result.PIBAttributeValue)

        result = self.dut.command( mlme.get.request( param))
        self.assertTrue( isinstance( result, mlme.get.confirm))
        
    def test_reset( self):
        result = self.dut.command( mlme.reset.request( True))
        self.assertTrue( isinstance( result, mlme.reset.confirm))
        self.assertEqual( result.status, chip.mac.status.SUCCESS)

    def test_get_set_wrong_attr( self):
        result = self.dut.command( mlme.set.request( "macWrongAttr", True))
        self.assertTrue( isinstance( result, mlme.set.confirm))
        self.assertEqual( result.status, chip.mac.status.UNSUPPORTED_ATTRIBUTE)
        self.assertEqual( result.PIBAttribute, "macWrongAttr")        
        result = self.dut.command( mlme.get.request( "macWrongAttr"))
        self.assertTrue( isinstance( result, mlme.get.confirm))
        self.assertEqual( result.status, chip.mac.status.UNSUPPORTED_ATTRIBUTE)
        self.assertEqual( result.PIBAttribute, "macWrongAttr")        
        
    def test_read_only( self):
        for param in ["macExtendedAddress",
                      "macCoordExtendedAddress",
                      "macMaxFrameTotalWaitTime",
                      "macLIFSPeriod",
                      "macSIFSPeriod",
                      "macRangingSupported",
                      "macTimestampSupported"]:
            set_result = self.dut.command( mlme.set.request( param, True))
            self.assertTrue( isinstance( set_result, mlme.set.confirm))
            self.assertEqual( set_result.status, chip.mac.status.READ_ONLY)
            # perform MLME-GET as well
            get_result = self.dut.command( mlme.get.request( param))
            self.assertTrue( isinstance( get_result, mlme.get.confirm))
            self.assertEqual( self.dut.pib[get_result.PIBAttribute][0],
                              get_result.PIBAttributeValue)


    def test_set_get( self):
        self.set_param( "macBattLifeExt", False, True)
        self.set_param( "macBattLifeExtPeriods", 6, 41)
        self.set_param( "macBeaconPayload",
                        0, 2 ** ( 8 * self.dut.pib['macBeaconPayloadLength'][0]))
        self.set_param( "macBeaconPayloadLength",
                        0, chip.mac.constants.aMaxBeaconPayloadLength)
        self.set_param( "macBeaconOrder", 0, 15)
        self.set_param( "macBeaconTxTime",
                        int( '0x000000', 16), int( '0xffffff', 16))
        self.set_param( "macBSN",
                        int( '0x00', 16), int( '0xff', 16))
        self.set_param( "macCoordShortAddress",
                        int( '0x0000', 16), int( '0xffff', 16))
        self.set_param( "macBSN",
                        int( '0x00', 16), int( '0xff', 16))
        self.set_param( "macGTSPermit", False, True)
        self.set_param( "macMaxBE" , 3, 8)
        self.set_param( "macMaxCSMABackoffs", 0, 5)
        self.set_param( "macMaxFrameRetries", 0, 7)
        self.set_param( "macMinBE", 0, self.dut.pib['macMaxBE'][0])
        self.set_param( "macPANId",
                        int( '0x0000', 16), int( '0xffff', 16))
        self.set_param( "macPromiscuousMode", False, True)
        self.set_param( "macResponseWaitTime", 2, 64)
        self.set_param( "macRxOnWhenIdle", False, True)
        self.set_param( "macSecurityEnabled", False, True)
        self.set_param( "macShortAddress",
                        int( '0x0000', 16), int( '0xffff', 16))
        self.set_param( "macSuperframeOrder", 0, 15)
        # FIXME: calculate range
        # self.set_param( "macSyncSymbolOffset", , )
        self.set_param( "macTransactionPersistenceTime",
                        int( '0x0000', 16), int( '0xffff', 16))
        self.set_param( "macTxControlActiveDuration", 0, 100000)
        self.set_param( "macTxControlPauseDuration", 0, 100000)
        self.set_param( "macTxTotalDuration",
                        int( '0x00000000', 16), int( '0xffffffff', 16))
        

if __name__ == '__main__':
    unittest.main()
