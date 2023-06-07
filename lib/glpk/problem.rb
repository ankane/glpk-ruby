module Glpk
  class Problem
    def initialize
      @model = FFI.glp_create_prob
      ObjectSpace.define_finalizer(@model, self.class.finalize(@model.to_i))
    end

    def load_problem(obj_dir:, obj_coef:, mat_ia:, mat_ja:, mat_ar:, col_kind:, col_lower:, col_upper:, row_lower:, row_upper:)
      num_cols = col_lower.size
      num_rows = row_lower.size
      ne = mat_ia.size

      # some checks will always pass
      check_size(obj_coef, num_cols)
      check_size(mat_ia, ne)
      check_size(mat_ja, ne)
      check_size(mat_ar, ne)
      check_size(col_kind, num_cols)
      check_size(col_lower, num_cols)
      check_size(col_upper, num_cols)
      check_size(row_lower, num_rows)
      check_size(row_upper, num_rows)

      FFI.glp_erase_prob(model)
      FFI.glp_add_rows(model, num_rows) if num_rows > 0
      FFI.glp_add_cols(model, num_cols)

      obj_coef.each_with_index do |v, i|
        FFI.glp_set_obj_coef(model, i + 1, v)
      end
      FFI.glp_set_obj_dir(model, FFI::OBJ_DIR.fetch(obj_dir))

      # indexing starts at 1
      ia = [0] + mat_ia
      ja = [0] + mat_ja
      ar = [0] + mat_ar
      FFI.glp_load_matrix(model, ne, int_array(ia), int_array(ja), double_array(ar))

      col_kind.each_with_index do |k, i|
        FFI.glp_set_col_kind(model, i + 1, FFI::COL_KIND.fetch(k))
      end

      col_lower.zip(col_upper).each_with_index do |(lb, ub), i|
        FFI.glp_set_col_bnds(model, i + 1, 4, lb, ub)
      end

      row_lower.zip(row_upper).each_with_index do |(lb, ub), i|
        FFI.glp_set_row_bnds(model, i + 1, row_type(lb, ub), lb, ub)
      end
    end

    def read_lp(filename)
      check_status FFI.glp_read_lp(model, nil, filename)
    end

    def read_mps(filename)
      check_status FFI.glp_read_mps(model, 2, nil, filename)
    end

    def write_lp(filename)
      check_status FFI.glp_write_lp(model, nil, filename)
    end

    def write_mps(filename)
      check_status FFI.glp_write_mps(model, 2, nil, filename)
    end

    def solve(**options)
      if FFI.glp_get_num_int(model) > 0
        solve_mip(**options)
      else
        solve_lp(**options)
      end
    end

    def self.finalize(addr)
      # must use proc instead of stabby lambda
      proc { FFI.glp_delete_prob(addr) }
    end

    private

    def model
      @model
    end

    def check_status(status)
      if status != 0
        raise Error, "Bad status: #{status}"
      end
    end

    def check_size(value, size)
      if value.size != size
        # TODO add variable name to message
        raise ArgumentError, "wrong size (given #{value.size}, expected #{size})"
      end
    end

    def double_array(value)
      base_array(value, "d")
    end

    def int_array(value)
      base_array(value, "i!")
    end

    def base_array(value, format)
      Fiddle::Pointer[value.pack("#{format}*")]
    end

    def solve_lp(message_level: 0, time_limit: nil)
      solve_simplex(message_level: message_level, time_limit: time_limit)

      num_rows = FFI.glp_get_num_rows(model)
      num_cols = FFI.glp_get_num_cols(model)

      {
        status: FFI::SOLUTION_STATUS[FFI.glp_get_status(model)],
        obj_val: FFI.glp_get_obj_val(model),
        row_primal: num_rows.times.map { |i| FFI.glp_get_row_prim(model, i + 1) },
        col_primal: num_cols.times.map { |i| FFI.glp_get_col_prim(model, i + 1) },
        row_dual: num_rows.times.map { |i| FFI.glp_get_row_dual(model, i + 1) },
        col_dual: num_cols.times.map { |i| FFI.glp_get_col_dual(model, i + 1) },
      }
    end

    def solve_mip(message_level: 0, time_limit: nil)
      solve_simplex(message_level: message_level, time_limit: time_limit)
      # TODO pass remaining time limit
      ret_code = solve_intopt(message_level: message_level, time_limit: time_limit)

      num_rows = FFI.glp_get_num_rows(model)
      num_cols = FFI.glp_get_num_cols(model)

      status = FFI::RET_CODE[ret_code] || FFI::SOLUTION_STATUS[FFI.glp_mip_status(model)]

      if status == :root_lp_optimum
        status = FFI::SOLUTION_STATUS[FFI.glp_get_status(model)]
      end

      {
        status: status,
        obj_val: FFI.glp_mip_obj_val(model),
        row_primal: num_rows.times.map { |i| FFI.glp_mip_row_val(model, i + 1) },
        col_primal: num_cols.times.map { |i| FFI.glp_mip_col_val(model, i + 1) }
      }
    end

    def solve_simplex(message_level:, time_limit:)
      param = FFI::Smcp.malloc
      FFI.glp_init_smcp(param)
      param.msg_lev = message_level
      param.tm_lim = (time_limit * 1000).ceil if time_limit
      FFI.glp_simplex(model, param)
    end

    def solve_intopt(message_level:, time_limit:)
      param = FFI::Iocp.malloc
      FFI.glp_init_iocp(param)
      param.msg_lev = message_level
      param.tm_lim = (time_limit * 1000).ceil if time_limit
      FFI.glp_intopt(model, param)
    end

    def row_type(lb, ub)
      if ub == Float::INFINITY
        if lb == -Float::INFINITY
          1 # unbounded
        else
          2 # lower bound
        end
      elsif lb == -Float::INFINITY
        3 # upper bound
      elsif lb == ub
        5 # fixed
      else
        4 # double-bounded
      end
    end
  end
end
