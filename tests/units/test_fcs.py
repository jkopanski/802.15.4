import unittest
import logging
import random

import numpy as np
import numpy.polynomial.polynomial as poly

import chip.bit as bit
import chip.mac
import chip.phy


class TestFCS( unittest.TestCase):
    def setUp( self):
        logging.basicConfig( format   = '%(asctime)s %(message)s', \
                             filename = 'test_fcs.log', \
                             filrmode = 'w+', \
                             level    = logging.DEBUG)
        self.phy = chip.phy.OQPSKPhy( chip.phy.band.MHz_780)
        self.dut = chip.mac.Mac( self.phy)

    def calc_np( self, data):
        coef = []
        # multiply by x^16
        # first beacouse of the convention which coefs are passed
        # 1 + x^1 + x^2 + ...
        for i in range( 16):
            coef.append( 0)

        for b in range( bit.len( data)):
            if bit.test( data, b):
                coef.append( 1)
            else:
                coef.append( 0)

        frame = poly.Polynomial( coef)
        gen   = poly.Polynomial( ( 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1))
        div, mod = divmod( frame, gen)
        mod.coef %= 2
        return mod(2)

    def test_fcs( self):
        for i in range( 32):
            data = random.randint( 2 ** 5, 2 ** 24)
            self.assertEqual(  self.calc_np( data), self.dut._fcs( data))


if __name__ == '__main__':
    unittest.main()
