import unittest
import logging
import chip.phy


class TestPHYCreation( unittest.TestCase):
    def setUp( self):
        logging.basicConfig( format   = '%(asctime)s %(message)s', \
                             filename = 'test_phy.log', \
                             filrmode = 'w+', \
                             level    = logging.DEBUG)
        
    def test_oqpsk( self):
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.OQPSKPhy, chip.phy.band.MHz_950)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.OQPSKPhy, chip.phy.band.UWB_SUB)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.OQPSKPhy, chip.phy.band.UWB_LOW)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.OQPSKPhy, chip.phy.band.UWB_HI)

    def test_bpsk( self):
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.BPSKPhy, chip.phy.band.MHz_780)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.BPSKPhy, chip.phy.band.MHz_2450)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.BPSKPhy, chip.phy.band.UWB_SUB)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.BPSKPhy, chip.phy.band.UWB_LOW)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.BPSKPhy, chip.phy.band.UWB_HI)

    def test_ask( self):
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.ASKPhy, chip.phy.band.MHz_780)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.ASKPhy, chip.phy.band.MHz_950)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.ASKPhy, chip.phy.band.MHz_2450)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.ASKPhy, chip.phy.band.UWB_SUB)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.ASKPhy, chip.phy.band.UWB_LOW)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.ASKPhy, chip.phy.band.UWB_HI)


if __name__ == '__main__':
    unittest.main()
