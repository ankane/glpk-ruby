module Glpk
  module FFI
    extend Fiddle::Importer

    libs = Array(Glpk.ffi_lib).dup
    begin
      dlload Fiddle.dlopen(libs.shift)
    rescue Fiddle::DLError => e
      retry if libs.any?
      raise e
    end

    COL_KIND = {
      continuous: 1,
      integer: 2,
      binary: 3
    }

    OBJ_DIR = {
      minimize: 1,
      maximize: 2
    }

    SOLUTION_STATUS = {
      1 => :undefined,
      2 => :feasible,
      3 => :infeasible,
      4 => :no_feasible,
      5 => :optimal,
      6 => :unbounded
    }

    RET_CODE = {
      1 => :invalid_basis,
      2 => :singular_matrix,
      3 => :ill_conditioned,
      4 => :invalid_bounds,
      5 => :failed,
      6 => :lower_limit_reached,
      7 => :upper_limit_reached,
      8 => :iteration_limit_reached,
      9 => :time_limit_reached,
      10 => :no_primal_feasible,
      11 => :no_dual_feasible,
      12 => :root_lp_optimum,
      13 => :terminated,
      14 => :mip_gap_tolerance_reached,
      15 => :no_primal_dual_feasible,
      16 => :no_convergence,
      17 => :numerical_instability,
      18 => :invalid_data,
      19 => :out_of_range
    }

    Smcp = struct [
      "int msg_lev",
      "int meth",
      "int pricing",
      "int r_test",
      "double tol_bnd",
      "double tol_dj",
      "double tol_piv",
      "double obj_ll",
      "double obj_ul",
      "int it_lim",
      "int tm_lim",
      "int out_frq",
      "int out_dly",
      "int presolve",
      "int excl",
      "int shift",
      "int aorn",
      "double foo_bar[33]"
    ]

    Iptcp = struct [
      "int msg_lev",
      "int ord_alg",
      "double foo_bar[48]"
    ]

    Iocp = struct [
      "int msg_lev",
      "int br_tech",
      "int bt_tech",
      "double tol_int",
      "double tol_obj",
      "int tm_lim",
      "int out_frq",
      "int out_dly",
      "void (*cb_func)(glp_tree *T, void *info)",
      "void *cb_info",
      "int cb_size",
      "int pp_tech",
      "double mip_gap",
      "int mir_cuts",
      "int gmi_cuts",
      "int cov_cuts",
      "int clq_cuts",
      "int presolve",
      "int binarize",
      "int fp_heur",
      "int ps_heur",
      "int ps_tm_lim",
      "int sr_heur",
      "int use_sol",
      "const char *save_sol",
      "int alien",
      "int flip",
      "double foo_bar[23]"
    ]

    extern "glp_prob *glp_create_prob(void)"
    extern "void glp_set_prob_name(glp_prob *P, char *name)"
    extern "void glp_set_obj_name(glp_prob *P, char *name)"
    extern "void glp_set_obj_dir(glp_prob *P, int dir)"
    extern "int glp_add_rows(glp_prob *P, int nrs)"
    extern "int glp_add_cols(glp_prob *P, int ncs)"
    extern "void glp_set_row_name(glp_prob *P, int i, char *name)"
    extern "void glp_set_col_name(glp_prob *P, int j, char *name)"
    extern "void glp_set_row_bnds(glp_prob *P, int i, int type, double lb, double ub)"
    extern "void glp_set_col_bnds(glp_prob *P, int j, int type, double lb, double ub)"
    extern "void glp_set_obj_coef(glp_prob *P, int j, double coef)"
    extern "void glp_set_mat_row(glp_prob *P, int i, int len, int ind[], double val[])"
    extern "void glp_set_mat_col(glp_prob *P, int j, int len, int ind[], double val[])"
    extern "void glp_load_matrix(glp_prob *P, int ne, int ia[], int ja[], double ar[])"
    extern "void glp_erase_prob(glp_prob *P)"
    extern "void glp_delete_prob(glp_prob *P)"
    extern "char *glp_get_prob_name(glp_prob *P)"
    extern "char *glp_get_obj_name(glp_prob *P)"
    extern "int glp_get_obj_dir(glp_prob *P)"
    extern "int glp_get_num_rows(glp_prob *P)"
    extern "int glp_get_num_cols(glp_prob *P)"

    # version info
    extern "char *glp_version(void)"

    # read and write
    extern "void glp_init_mpscp(glp_mpscp *parm)"
    extern "int glp_read_mps(glp_prob *P, int fmt, glp_mpscp *parm, char *fname)"
    extern "int glp_write_mps(glp_prob *P, int fmt, glp_mpscp *parm, char *fname)"
    extern "void glp_init_cpxcp(glp_cpxcp *parm)"
    extern "int glp_read_lp(glp_prob *P, glp_cpxcp *parm, char *fname)"
    extern "int glp_write_lp(glp_prob *P, glp_cpxcp *parm, char *fname)"
    extern "int glp_read_prob(glp_prob *P, int flags, char *fname)"
    extern "int glp_write_prob(glp_prob *P, int flags, char *fname)"

    # lp
    extern "int glp_simplex(glp_prob *P, glp_smcp *parm)"
    extern "int glp_exact(glp_prob *P, glp_smcp *parm)"
    extern "void glp_init_smcp(glp_smcp *parm)"
    extern "int glp_get_status(glp_prob *P)"
    extern "int glp_get_prim_stat(glp_prob *P)"
    extern "int glp_get_dual_stat(glp_prob *P)"
    extern "double glp_get_obj_val(glp_prob *P)"
    extern "int glp_get_row_stat(glp_prob *P, int i)"
    extern "double glp_get_row_prim(glp_prob *P, int i)"
    extern "double glp_get_row_dual(glp_prob *P, int i)"
    extern "int glp_get_col_stat(glp_prob *P, int j)"
    extern "double glp_get_col_prim(glp_prob *P, int j)"
    extern "double glp_get_col_dual(glp_prob *P, int j)"

    # mip
    extern "void glp_set_col_kind(glp_prob *P, int j, int kind)"
    extern "int glp_get_col_kind(glp_prob *P, int j)"
    extern "int glp_get_num_int(glp_prob *P)"
    extern "int glp_get_num_bin(glp_prob *P)"
    extern "int glp_intopt(glp_prob *P, glp_iocp *parm)"
    extern "void glp_init_iocp(glp_iocp *parm)"
    extern "int glp_mip_status(glp_prob *P)"
    extern "double glp_mip_obj_val(glp_prob *P)"
    extern "double glp_mip_row_val(glp_prob *P, int i)"
    extern "double glp_mip_col_val(glp_prob *P, int j)"
  end
end
