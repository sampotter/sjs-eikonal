#pragma once

#include "def.h"

/* If `order == ORDER_ROW_MAJOR`, then the indexing/coordinate
 * convention that is used is:
 *
 *       +j/+y
 *   o---------->
 *   |
 *   |
 *   |
 *   |+i/+x
 *   |
 *   v
 *
 * Here, the "o" denotes the origin, where (i, j) = (0, 0) and (x, y)
 * = (0, 0). We have shown the coordinate system oriented so that it
 * matches the typical matrix indexing convention for languages that
 * are row major. E.g., a numpy array `arr`, indexed `arr[i, j]`, is
 * laid out as shown on the page. To get the usual x-y plane, we can
 * rotate this picture counterclockwise 90 degrees.
 *
 * Note: `order == ORDER_COLUMN_MAJOR` isn't implemented yet, but the
 * idea is that once it is, it will be straightforward to wrap this
 * library for languages which are column major by convention (MATLAB,
 * R, Fortran, Julia, ...). */
typedef struct grid2 {
  int2 shape;
  dbl2 xymin;
  dbl h;
  order_e order;
} grid2_s;

size_t grid2_nind(grid2_s const *grid);
size_t grid2_nindc(grid2_s const *grid);
int grid2_ind2l(grid2_s const *grid, int2 const ind);
int grid2_ind2lc(grid2_s const *grid, int2 const ind);
int grid2_indc2l(grid2_s const *grid, int2 const indc);
int grid2_indc2lc(grid2_s const *grid, int2 const indc);
void grid2_l2ind(grid2_s const *grid, int l, int2 ind);
void grid2_l2indc(grid2_s const *grid, int l, int2 indc);
void grid2_lc2ind(grid2_s const *grid, int lc, int2 ind);
void grid2_lc2indc(grid2_s const *grid, int lc, int2 indc);
int grid2_l2lc(grid2_s const *grid, int l);
int grid2_lc2l(grid2_s const *grid, int lc);
void grid2_l2xy(grid2_s const *grid, int l, dbl2 xy);
int grid2_xy2lc(grid2_s const *grid, dbl2 const xy, dbl2 cc);
bool grid2_isind(grid2_s const *grid, int2 ind);
bool grid2_isindc(grid2_s const *grid, int2 indc);