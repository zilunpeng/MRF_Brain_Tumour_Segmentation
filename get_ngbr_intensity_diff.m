function [up_id, down_id, left_id, right_id, ul_id, ur_id, dl_id, dr_id, slice_above_id, slice_below_id] = get_ngbr_intensity_diff(center_vx_intensity, intensity_mat, ngbr_vx_idx)
    up_id = center_vx_intensity - intensity_mat(:, ngbr_vx_idx{1});
    down_id = center_vx_intensity - intensity_mat(:, ngbr_vx_idx{2});
    left_id = center_vx_intensity - intensity_mat(:, ngbr_vx_idx{3});
    right_id = center_vx_intensity - intensity_mat(:, ngbr_vx_idx{4});
    ul_id = center_vx_intensity - intensity_mat(:, ngbr_vx_idx{5});
    ur_id = center_vx_intensity - intensity_mat(:, ngbr_vx_idx{6});
    dl_id = center_vx_intensity - intensity_mat(:, ngbr_vx_idx{7});
    dr_id = center_vx_intensity - intensity_mat(:, ngbr_vx_idx{8});
    slice_above_id = center_vx_intensity - intensity_mat(:, ngbr_vx_idx{9});
    slice_below_id = center_vx_intensity - intensity_mat(:, ngbr_vx_idx{10});
end