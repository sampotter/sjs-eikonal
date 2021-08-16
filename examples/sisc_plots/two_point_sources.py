import colorcet as cc
import itertools as it
import matplotlib.pyplot as plt
import numpy as np

from jmm.eik import Eik
from jmm.field import LinearSpeedFunc2
from jmm.grid import Grid2

def get_trial_mask(valid_mask):
    shape = valid_mask.shape
    trial_mask = np.zeros_like(valid_mask)
    for i, j in it.product(*(range(dim) for dim in shape)):
        if valid_mask[i, j]:
            continue
        for di, dj in it.product([-1, 0, 1], repeat=2):
            if 0 <= i + di < shape[0] and \
               0 <= j + dj < shape[1] and \
               valid_mask[i + di, j + dj]:
                trial_mask[i, j] = True
    return trial_mask

if __name__ == '__main__':
    plt.ion()

    # Speed function
    x0, y0 = 0, 0
    x1, y1 = 0.8, 0
    c0 = np.array([0.5, 5, 20])
    c1 = c0 + np.array([c0[1]*x1 + c0[2]*y1, 0, 0])

    # Discretization parameters
    h = 0.01
    xmin, ymin = 0, 0
    xmax, ymax = 1, 0.5
    M = int(np.round(xmax/h)) + 1
    N = int(np.round(ymax/h)) + 1
    shape = np.array([M, N], dtype=np.intc)
    xymin = np.array([xmin, ymin], dtype=np.float64)
    grid = Grid2(shape, xymin, h)
    rfac = 0.1
    x, y = np.meshgrid(np.linspace(xmin, xmax, M),
                       np.linspace(ymin, ymax, N),
                       indexing='ij')

    def get_eik_for_pt_src(c, x0, y0):
        s = LinearSpeedFunc2(c, x0, y0)
        eik = Eik.from_s_and_grid(s, grid)
        valid_mask = (x0 - x)**2 + (y0 - y)**2 < rfac**2
        for i, j in zip(*np.where(valid_mask)):
            ind = np.array([i, j], dtype=np.intc)
            eik.add_valid(ind, s.get_jet(x[i, j], y[i, j]))
        for i, j in zip(*np.where(get_trial_mask(valid_mask))):
            ind = np.array([i, j], dtype=np.intc)
            eik.add_trial(ind, s.get_jet(x[i, j], y[i, j]))
        eik.build_cells()
        return eik

    print('eik0')
    eik0 = get_eik_for_pt_src(c0, x0, y0)
    eik0.solve()

    print('eik1')
    eik1 = get_eik_for_pt_src(c1, x1, y1)
    eik1.solve()

    ########################################################################
    # debugging

    # FIXME: this is computing the same thing as if I had passed "0,
    # 0" below instead of "0.8, 0".
    s = LinearSpeedFunc2(c, 0, 0)

    T = np.empty_like(x)
    for i, j in it.product(range(M), range(N)):
        T[i, j] = s.tau(x[i, j], y[i, j])

    Tx = np.empty_like(x)
    for i, j in it.product(range(M), range(N)):
        Tx[i, j] = s.taux(x[i, j], y[i, j])

    Ty = np.empty_like(x)
    for i, j in it.product(range(M), range(N)):
        Ty[i, j] = s.tauy(x[i, j], y[i, j])

    Txx = np.empty_like(x)
    for i, j in it.product(range(M), range(N)):
        Txx[i, j] = s.tauxx(x[i, j], y[i, j])

    Txy = np.empty_like(x)
    for i, j in it.product(range(M), range(N)):
        Txy[i, j] = s.tauxy(x[i, j], y[i, j])

    Tyy = np.empty_like(x)
    for i, j in it.product(range(M), range(N)):
        Tyy[i, j] = s.tauyy(x[i, j], y[i, j])

    Tx_fd, Ty_fd = np.gradient(T, h, h, edge_order=2)
    Txx_fd, Txy_fd = np.gradient(Tx, h, h, edge_order=2)
    Tyx_fd, Tyy_fd = np.gradient(Ty, h, h, edge_order=2)

    extent = [xmin, xmax, ymin, ymax]

    plt.figure(figsize=(9, 4))
    # plt.imshow(np.rot90(eik0.T), extent=extent)
    plt.imshow(np.rot90(np.log10(abs(eik0.T - T))), extent=extent, cmap=cc.cm.rainbow)
    # plt.imshow(np.rot90(np.minimum(eik0.T, eik1.T)), extent=extent, cmap=cc.cm.rainbow)
    # plt.contourf(x, y, eik0.T)
    plt.colorbar()
    plt.gca().set_aspect('equal')
    plt.tight_layout()
    plt.show()
