import numpy as np

from libc.string cimport memcpy

cdef class Parent3:
    def __cinit__(self, par3 par):
        self.par = par

    @property
    def size(self):
        return par3_size(&self.par)

    @property
    def l(self):
        cdef size_t[:] l = np.empty((self.size,), dtype=np.uintp)
        memcpy(&l[0], self.par.l, self.size*sizeof(size_t))
        return np.asarray(l)

    @property
    def b(self):
        cdef dbl[:] b = np.empty((self.size,), dtype=np.float64)
        memcpy(&b[0], self.par.b, self.size*sizeof(dbl))
        return np.asarray(b)

    @property
    def num_active(self):
        return par3_num_active(&self.par)

    def get_active(self):
        cdef size_t num_active = self.num_active
        cdef size_t[::1] l = np.empty(num_active, dtype=np.uintp)
        cdef dbl[::1] b = np.empty(num_active, dtype=np.float64)
        par3_get_active(&self.par, &l[0], &b[0])
        return np.asarray(l), np.asarray(b)
