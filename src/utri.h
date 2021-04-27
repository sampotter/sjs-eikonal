#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include "common.h"
#include "jet.h"
#include "par.h"

typedef struct utri_spec {
  eik3_s const *eik;
  size_t lhat, l[2];
  state_e state[2];
  dbl xhat[3], x[2][3];
  jet3 jet[2];
  size_t orig_index;
} utri_spec_s;

utri_spec_s utri_spec_empty();
utri_spec_s utri_spec_from_eik(eik3_s const *eik, size_t l, size_t l0, size_t l1);
utri_spec_s utri_spec_from_eik_without_l(eik3_s const *eik, dbl const x[3],
                                         size_t l0, size_t l1);
utri_spec_s utri_spec_from_raw_data(dbl const x[3], dbl const Xt[2][3], jet3 jet[2]);

typedef struct utri utri_s;

void utri_alloc(utri_s **utri);
void utri_dealloc(utri_s **utri);
bool utri_init(utri_s *u, utri_spec_s const *spec);
void utri_deinit(utri_s *u);
void utri_solve(utri_s *utri);
par3_s utri_get_par(utri_s const *u);
dbl utri_get_value(utri_s const *utri);
void utri_get_jet(utri_s const *utri, jet3 *jet);
bool utri_update_ray_is_physical(utri_s const *utri, eik3_s const *eik);
int utri_cmp(utri_s const **h1, utri_s const **h2);
bool utri_has_interior_point_solution(utri_s const *utri);
bool utri_has_orig_index(utri_s const *utri);
size_t utri_get_orig_index(utri_s const *utri);
bool utri_is_finite(utri_s const *utri);
size_t utri_get_active_ind(utri_s const *utri);
size_t utri_get_inactive_ind(utri_s const *utri);
bool utri_contains_update_ind(utri_s const *utri, size_t l);
size_t utri_get_l(utri_s const *utri);

bool utris_yield_same_update(utri_s const *utri1, utri_s const *utri2);

#if JMM_TEST
bool utri_is_causal(utri_s const *utri);
dbl utri_get_lambda(utri_s const *utri);
#endif

#ifdef __cplusplus
}
#endif
