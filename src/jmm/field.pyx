import numpy as np

from libc.string cimport memcpy

from jmm.jet cimport Jet2

cdef dbl dacosh(dbl z):
  return 1/np.sqrt((z - 1)*(z + 1))

cdef dbl d2acosh(dbl z):
  return -z*((z - 1)*(z + 1))**-1.5

cdef class SlownessFunc2:
    pass

cdef dbl linear_speed_func_2_f(dbl x, dbl y, void *context):
    cdef LinearSpeedFunc2 lsf = <LinearSpeedFunc2>context
    cdef dbl *c = lsf.c
    cdef dbl dx = x - lsf.x0
    cdef dbl dy = y - lsf.y0
    return 1/(c[0] + c[1]*dx + c[2]*dy)

cdef void linear_speed_func_2_grad_f(dbl x, dbl y, void *context, dbl2 g):
    cdef LinearSpeedFunc2 lsf = <LinearSpeedFunc2>context
    cdef dbl *c = lsf.c
    cdef dbl dx = x - lsf.x0
    cdef dbl dy = y - lsf.y0
    cdef dbl f_sq = 1/(c[0] + c[1]*dx + c[2]*dy)**2
    g[0] = -c[1]*f_sq
    g[1] = -c[2]*f_sq

cdef class LinearSpeedFunc2(SlownessFunc2):
    def __cinit__(self, dbl[::1] c, dbl x0, dbl y0):
        if len(c) != 3:
            raise ValueError('c should be an array of 3 coefficients')
        memcpy(&self.c[0], &c[0], sizeof(dbl[3]))
        self.x0 = x0
        self.y0 = y0
        self.field.f = linear_speed_func_2_f
        self.field.grad_f = linear_speed_func_2_grad_f
        self.field.context = <void *>self

    @property
    def s0(self):
        return 1/self.c[0]

    @property
    def v(self):
        return self.c[1], self.c[2]

    def s(self, dbl x, dbl y):
        cdef dbl dx = x - self.x0
        cdef dbl dy = y - self.y0
        return 1.0/(self.c[0] + self.c[1]*dx + self.c[2]*dy)

    def sx(self, dbl x, dbl y):
        return -self.c[1]*self.s(x, y)**2

    def sy(self, dbl x, dbl y):
        return -self.c[2]*self.s(x, y)**2

    def sxx(self, dbl x, dbl y):
        return 2*self.c[1]**2*self.s(x, y)**2

    def sxy(self, dbl x, dbl y):
        return 2*self.c[1]*self.c[2]*self.s(x, y)**2

    def syy(self, dbl x, dbl y):
        return 2*self.c[2]**2*self.s(x, y)**2

    @property
    def vnormsq(self):
        return self.c[1]*self.c[1] + self.c[2]*self.c[2]

    @property
    def vnorm(self):
        return np.sqrt(self.vnormsq)

    @property
    def scale(self):
        return self.vnormsq/(2*self.c[0])

    def normsq(self, dbl x, dbl y):
        return (x - self.x0)**2 + (y - self.y0)**2

    def f(self, dbl x, dbl y):
        return 1 + self.scale*self.s(x, y)*self.normsq(x, y)

    def fx(self, dbl x, dbl y):
        cdef dbl dx = x - self.x0
        return self.scale*(self.sx(x, y)*self.normsq(x, y) + 2*self.s(x, y)*dx)

    def fy(self, dbl x, dbl y):
        cdef dbl dy = y - self.y0
        return self.scale*(self.sy(x, y)*self.normsq(x, y) + 2*self.s(x, y)*dy)

    def fxx(self, dbl x, dbl y):
        cdef dbl dx = x - self.x0
        return self.scale*(
            self.sxx(x, y)*self.normsq(x, y) + 4*self.sx(x, y)*dx + 2*self.s(x, y))

    def fxy(self, dbl x, dbl y):
        cdef dbl dx = x - self.x0
        cdef dbl dy = y - self.y0
        return self.scale*(
            self.sxy(x, y)*self.normsq(x, y) + 2*(self.sx(x, y)*dy + self.sy(x, y)*dx))

    def fyy(self, dbl x, dbl y):
        cdef dbl dy = y - self.y0
        return self.scale*(
            self.syy(x, y)*self.normsq(x, y) + 4*self.sy(x, y)*dy + 2*self.s(x, y))

    def tau(self, dbl x, dbl y):
        return np.arccosh(self.f(x, y))/self.vnorm

    def taux(self, dbl x, dbl y):
        return dacosh(self.f(x, y))*self.fx(x, y)/self.vnorm

    def tauy(self, dbl x, dbl y):
        return dacosh(self.f(x, y))*self.fy(x, y)/self.vnorm

    def tauxx(self, dbl x, dbl y):
        cdef dbl f = self.f(x, y)
        cdef dbl fx = self.fx(x, y)
        return (d2acosh(f)*fx**2 + dacosh(f)*self.fxx(x, y))/self.vnorm

    def tauxy(self, dbl x, dbl y):
        cdef dbl f = self.f(x, y)
        return (
            d2acosh(f)*self.fx(x, y)*self.fy(x, y) + dacosh(f)*self.fxy(x, y)
        )/self.vnorm

    def tauyy(self, dbl x, dbl y):
        cdef dbl f = self.f(x, y)
        cdef dbl fy = self.fy(x, y)
        return (d2acosh(f)*fy**2 + dacosh(f)*self.fyy(x, y))/self.vnorm

    def get_jet(self, x, y):
        return Jet2(
            self.tau(x, y),
            self.taux(x, y),
            self.tauy(x, y),
            self.tauxy(x, y)
        )
