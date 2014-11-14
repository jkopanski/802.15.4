import unittest
import logging
import cocotb
import chip.phy

from cocotb.binary import BinaryValue


class TestPHY( unittest.TestCase):
    def setUp( self):
        logging.basicConfig( format   = '%(asctime)s %(message)s', \
                             filename = 'test_phy.log', \
                             filrmode = 'w+', \
                             level    = logging.DEBUG)
    
    @cocotb.test()
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

    def test_css( self):
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.CSSPhy, chip.phy.band.MHz_780)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.ASKPhy, chip.phy.band.MHz_2450)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.ASKPhy, chip.phy.band.UWB_SUB)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.ASKPhy, chip.phy.band.UWB_LOW)
        self.assertRaises( chip.phy.PhyFreqError,
                           chip.phy.ASKPhy, chip.phy.band.UWB_HI)

    def test_oqpsk_ppdu( self):
        phy = chip.phy.OQPSKPhy( chip.phy.band.MHz_780)
        val = BinaryValue( random.randint( -2, 2*2**consts.aMaxPHYPacketSize))
        if val.len < 5 or \
           ( load.len > 6 and load.len < 9) or \
           load.len > constants.aMaxPHYPacketSize:
            self.assertRises( chip.phyPPDUError, phy.ppdu, val)
        else:
            ret = phy.ppdu( val)
            self.assertEqual( phy.preamble,    ret[0:15])
            self.assertEqual( phy.sfd,         ret[16:23])
            self.assertEqual( val.len,         ret[24:30])
            self.assertEqual( BinaryValue( 0), ret[30])
            self.assertEqual( valphy.preamble, ret[31:])


if __name__ == '__main__':
    unittest.main()
