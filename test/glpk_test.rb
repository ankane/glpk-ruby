require_relative "test_helper"

class GlpkTest < Minitest::Test
  def test_lib_version
    assert_match(/\A\d+\.\d+\z/, Glpk.lib_version)
  end

  def test_load_problem_mip
    model =
      Glpk.load_problem(
        obj_dir: :minimize,
        obj_coef: [8, 10],
        mat_ia: [1, 2, 3, 1, 2, 3],
        mat_ja: [1, 1, 1, 2, 2, 2],
        mat_ar: [2, 3, 2, 2, 4, 1],
        col_kind: [:integer, :integer],
        col_lower: [0, 0],
        col_upper: [1e30, 1e30],
        row_lower: [7, 12, 6],
        row_upper: [1e30, 1e30, 1e30]
      )

    model.write_mps("/tmp/test.mps")
    assert_equal File.binread("test/support/test.mps"), File.binread("/tmp/test.mps")

    # adds columns
    model.write_lp("/tmp/test.lp")
    assert_equal File.binread("test/support/test.lp"), File.binread("/tmp/test.lp")

    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta 32, res[:obj_val]
    assert_elements_in_delta [8, 12, 8], res[:row_primal]
    assert_elements_in_delta [4, 0], res[:col_primal]
  end

  def test_load_problem_lp
    model =
      Glpk.load_problem(
        obj_dir: :minimize,
        obj_coef: [8, 10],
        mat_ia: [1, 2, 3, 1, 2, 3],
        mat_ja: [1, 1, 1, 2, 2, 2],
        mat_ar: [2, 3, 2, 2, 4, 1],
        col_kind: [:continuous, :continuous],
        col_lower: [0, 0],
        col_upper: [1e30, 1e30],
        row_lower: [7, 12, 6],
        row_upper: [1e30, 1e30, 1e30]
      )

    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta 31.2, res[:obj_val]
    assert_elements_in_delta [7.2, 12, 6], res[:row_primal]
    assert_elements_in_delta [2.4, 1.2], res[:col_primal]
    assert_elements_in_delta [0, 2.4, 0.4], res[:row_dual]
    assert_elements_in_delta [0, 0], res[:col_dual]
  end

  def test_read_lp
    model = Glpk.read_lp("test/support/test.lp")
    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta 32, res[:obj_val]
    # adding last 3 elements of col_prim to row_prim
    # gives result consistent with mps
    assert_elements_in_delta [7, 12, 6], res[:row_primal]
    assert_elements_in_delta [4, 0, 1, 0, 2], res[:col_primal]
  end

  def test_read_mps
    model = Glpk.read_mps("test/support/test.mps")
    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta 32, res[:obj_val]
    assert_elements_in_delta [8, 12, 8], res[:row_primal]
    assert_elements_in_delta [4, 0], res[:col_primal]
  end

  def test_time_limit
    model = Glpk.read_lp("test/support/test.lp")
    res = model.solve(time_limit: 0.000001)
    assert_equal :time_limit_reached, res[:status]
  end

  def test_copy
    model = Glpk.read_lp("test/support/test.lp")
    model.dup
    model.clone
  end

  def test_free
    model = Glpk.read_lp("test/support/test.lp")
    model.free
    error = assert_raises(Glpk::Error) do
      model.solve
    end
    assert_equal "can't use freed problem", error.message
  end

  def test_threads
    threads =
      2.times.map do
        Thread.new do
          model = Glpk.read_lp("test/support/test.lp")
          model.solve
          model.free
        end
      end
    threads.map(&:join)
  end
end
