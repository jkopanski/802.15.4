import unittest
import logging
import chip.mac
import chip.phy

class TestMAC( unittest.TestCase):
    def setUp( self):
        logging.basicConfig( format   = '%(asctime)s %(message)s', \
                             filename = 'test_mac.log', \
                             filrmode = 'w+', \
                             level    = logging.DEBUG)
        self.phy = chip.phy.Phy( chip.phy.phyType.OQPSK)
        self.dut = chip.mac.Mac( self.phy)

    def test_reset( self):
        result = self.dut.command( chip.mac.mlme.reset.request( True))
        self.assertTrue( isinstance( result, chip.mac.mlme.reset.confirm))
        self.assertEqual( result.status, chip.mac.enum.SUCCESS)

if __name__ == '__main__':
    unittest.main()
