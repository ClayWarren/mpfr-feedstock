#include <stdio.h>
#include <mpfr.h>

#define CHECK(x) do { if (!(x)) { fprintf(stderr, "Failed: %s (line %d)\n", #x, __LINE__); return 1; } } while (0)

int main(void) {
    mpfr_t lower, upper, x, y;
    mpfr_inits2(200, lower, upper, x, y, (mpfr_ptr)0);
    CHECK(mpfr_buildopt_tls_p());
    mpfr_set_ui(x, 2, MPFR_RNDN);
    CHECK(mpfr_sqrt(lower, x, MPFR_RNDD) < 0);
    CHECK(mpfr_sqrt(upper, x, MPFR_RNDU) > 0);
    CHECK(mpfr_cmp(lower, upper) < 0);
    mpfr_mul(y, lower, lower, MPFR_RNDD);
    CHECK(mpfr_cmp_ui(y, 2) < 0);
    mpfr_mul(y, upper, upper, MPFR_RNDU);
    CHECK(mpfr_cmp_ui(y, 2) > 0);
    mpfr_set_prec(x, 53);
    mpfr_set_ui(x, 1, MPFR_RNDN);
    CHECK(mpfr_div_ui(x, x, 10, MPFR_RNDD) < 0);
    CHECK(mpfr_cmp_d(x, 0.1) < 0);
    mpfr_set_ui(x, 1, MPFR_RNDN);
    CHECK(mpfr_div_ui(x, x, 10, MPFR_RNDU) > 0);
    CHECK(mpfr_cmp_d(x, 0.1) == 0);
#if defined(_M_ARM64) || defined(__aarch64__)
    /* Native Clang and MSVC share the Windows ARM64 long-double ABI. */
    CHECK(mpfr_set_ld(y, 1.25L, MPFR_RNDN) == 0);
    CHECK(mpfr_get_ld(y, MPFR_RNDN) == 1.25L);
#endif
    mpfr_clears(lower, upper, x, y, (mpfr_ptr)0);
    mpfr_free_cache();
    printf("MPFR %s: precision, directed rounding, TLS and ABI consumer passed\n", mpfr_get_version());
    return 0;
}
