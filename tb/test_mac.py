import unittest
import logging
import chip.mac
import chip.phy
import chip.mlme as mlme

class TestMAC( unittest.TestCase):
    def setUp( self):
        logging.basicConfig( format   = '%(asctime)s %(message)s', \
                             filename = 'test_mac.log', \
                             filrmode = 'w+', \
                             level    = logging.DEBUG)
        self.phy = chip.phy.Phy( chip.phy.phyType.OQPSK)
        self.dut = chip.mac.Mac( self.phy)

    def test_reset( self):
        result = self.dut.command( mlme.reset.request( True))
        self.assertTrue( isinstance( result, mlme.reset.confirm))
        self.assertEqual( result.status, chip.mac.status.SUCCESS)

    def test_set( self):
        result = self.dut.command( mlme.set.request( "macBattLifeExt", True))
    def test_set_wrong_attr( self):
        result = self.dut.command( mlme.set.request( "macWrongAttr", True))
        self.assertTrue( isinstance( result, mlme.set.confirm))
        self.assertEqual( result.status, chip.mac.status.UNSUPPORTED_ATTRIBUTE)
        self.assertEqual( result.PIBAttribute, "macWrongAttr")
if __name__ == '__main__':
    unittest.main()
