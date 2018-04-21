%% Return probability of every voxel being a healty tissue
function [healthy_prob_center_vx, healthy_prob_neighbor_vx] = get_vx_class_prob(i, center_idx, ngbr_vx_idx)
    healthy_cls_prob = read_healthy_class_prob(i);
    gm_prob = healthy_cls_prob{1};
    wm_prob = healthy_cls_prob{2};
    csf_prob = healthy_cls_prob{3};

    [numRows,numCols,numSlices] = size(gm_prob);
    total_vx = numRows*numCols*numSlices;
    healthy_prob = [reshape(gm_prob,1,total_vx);reshape(wm_prob,1,total_vx);reshape(csf_prob,1,total_vx)];
    healthy_prob_center_vx = healthy_prob(:,center_idx);
    
    healthy_prob_neighbor_vx{1} = healthy_prob(:,ngbr_vx_idx{1});
    healthy_prob_neighbor_vx{2} = healthy_prob(:,ngbr_vx_idx{2});
    healthy_prob_neighbor_vx{3} = healthy_prob(:,ngbr_vx_idx{3});
    healthy_prob_neighbor_vx{4} = healthy_prob(:,ngbr_vx_idx{4});
    healthy_prob_neighbor_vx{5} = healthy_prob(:,ngbr_vx_idx{5});
    healthy_prob_neighbor_vx{6} = healthy_prob(:,ngbr_vx_idx{6});
    healthy_prob_neighbor_vx{7} = healthy_prob(:,ngbr_vx_idx{7});
    healthy_prob_neighbor_vx{8} = healthy_prob(:,ngbr_vx_idx{8});
    healthy_prob_neighbor_vx{9} = healthy_prob(:,ngbr_vx_idx{9});
    healthy_prob_neighbor_vx{10} = healthy_prob(:,ngbr_vx_idx{10});    
end