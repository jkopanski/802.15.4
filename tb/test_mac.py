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
        self.phy = chip.phy.OQPSKPhy( chip.phy.band.MHz_780)
        self.dut = chip.mac.Mac( self.phy)

    def test_reset( self):
        result = self.dut.command( mlme.reset.request( True))
        self.assertTrue( isinstance( result, mlme.reset.confirm))
        self.assertEqual( result.status, chip.mac.status.SUCCESS)
        

if __name__ == '__main__':
    unittest.main()
