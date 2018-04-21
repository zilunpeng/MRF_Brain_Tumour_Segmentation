function [ground_truth_center_vx, ground_truth_neighbor_vx] = get_ground_truth_label(i, center_idx, ngbr_vx_idx)
        ground_truth = get_ground_truth(i);
        [numRows,numCols,numSlices] = size(ground_truth);
        total_vx = numRows*numCols*numSlices;
        ground_truth = reshape(ground_truth, [1, total_vx]); 
        ground_truth_center_vx = ground_truth(center_idx);
        
        ground_truth_neighbor_vx{1} = ground_truth(ngbr_vx_idx{1});
        ground_truth_neighbor_vx{2} = ground_truth(ngbr_vx_idx{2});
        ground_truth_neighbor_vx{3} = ground_truth(ngbr_vx_idx{3});
        ground_truth_neighbor_vx{4} = ground_truth(ngbr_vx_idx{4});
        ground_truth_neighbor_vx{5} = ground_truth(ngbr_vx_idx{5});
        ground_truth_neighbor_vx{6} = ground_truth(ngbr_vx_idx{6});
        ground_truth_neighbor_vx{7} = ground_truth(ngbr_vx_idx{7});
        ground_truth_neighbor_vx{8} = ground_truth(ngbr_vx_idx{8});
        ground_truth_neighbor_vx{9} = ground_truth(ngbr_vx_idx{9});
        ground_truth_neighbor_vx{10} = ground_truth(ngbr_vx_idx{10});
end