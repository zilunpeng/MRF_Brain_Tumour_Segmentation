function [classified_mri] = ICM(multiplier, num_neighbors, numRows, numCols, numSlices, num_cls, gab_bayes_prior, sum_intensity, vx_intensities, GMRF_params, three_clique)
    intensity_given_cls_mean = GMRF_params.igc_mean;
    intensity_given_cls_cov = GMRF_params.igc_cov;
    id_given_two_cls_mean = GMRF_params.id_twoCls_mean;
    id_given_two_cls_cov = GMRF_params.id_twoCls_cov;
    co_occ = GMRF_params.co_occ;
    if three_clique
       id_given_three_cls_mean = GMRF_params.id_treCls_mean;
       id_given_three_cls_cov = GMRF_params.id_treCls_cov;
       three_cqe_ngbrs = [1 5;5 3; 3 7;7 2;2 8;8 4;4 6;6 1];       
    end

    
    
    cls_assignment = zeros(numRows, numCols, numSlices);
   
    for cur_slice = 2:numSlices-1 %ignore first and last slice
        sum_intensity_cur_slice = sum_intensity(:,:,cur_slice);
        [valid_rows, valid_cols] = find(sum_intensity_cur_slice>0); %1=out of brain 0=inside brain
        valid_indicies = sub2ind([numRows, numCols, numSlices], valid_rows, valid_cols, repelem(cur_slice,length(valid_rows),1));
        num_valid_idx = length(valid_indicies);        
        cls_assignment(valid_indicies) = initialize_ICM(num_cls, intensity_given_cls_mean, intensity_given_cls_cov, vx_intensities(:,valid_indicies), gab_bayes_prior(:,valid_indicies));
        if ~isempty(valid_indicies)
            for i=1:num_valid_idx*multiplier
                temp = randsample(1:num_valid_idx,1); center_idx = valid_indicies(temp);
                ngbr_vx_idx = get_neighbor_vx_idx(center_idx, numRows, numCols);
                center_vx_intensity = vx_intensities(:,center_idx);
                
                posterior = log(gab_bayes_prior(:,center_idx));
                if any(isnan(posterior))
                   posterior = zeros(num_cls,1);
                end
                
                for cur_cls = 1:num_cls
                    posterior(cur_cls) = posterior(cur_cls) + log(mvnpdf(center_vx_intensity', intensity_given_cls_mean(cur_cls,:), intensity_given_cls_cov(:,:,cur_cls)));                    
                    for cur_ngbr = 1:num_neighbors
                        ngbr_idx = ngbr_vx_idx{cur_ngbr};
                        if any(valid_indicies == ngbr_idx)
                            ngbr_cls = cls_assignment(ngbr_idx);
                            cur_ngbr_id = center_vx_intensity - vx_intensities(:,ngbr_idx);
                            temp = sub2ind([num_cls, num_cls], ngbr_cls, cur_cls);
                            posterior(cur_cls) = posterior(cur_cls) + log(mvnpdf(cur_ngbr_id', id_given_two_cls_mean(temp,:), id_given_two_cls_cov(:,:,temp))) + co_occ(temp);
                        end
                    end
                end
                
                if three_clique
                   for n=1:num_neighbors
                       ngbr = three_cqe_ngbrs(n,:);
                       ngbr1 = ngbr(1);
                       ngbr2 = ngbr(2);
                       ngbr1_idx = ngbr_vx_idx{ngbr1}; ngbr2_idx = ngbr_vx_idx{ngbr2};
                       if any(valid_indicies == ngbr1_idx) && any(valid_indicies == ngbr2_idx)
                          ngbr1_cls = cls_assignment(ngbr1_idx); ngbr2_cls = cls_assignment(ngbr2_idx);
                          cur_ngbr_id = [center_vx_intensity - vx_intensities(:,ngbr1_idx), center_vx_intensity - vx_intensities(:,ngbr2_idx)];
                          temp = sub2ind([num_cls, num_cls, num_cls], ngbr1_cls, ngbr2_cls, cur_cls);
                          posterior(cur_cls) = posterior(cur_cls) + log(mvnpdf(cur_ngbr_id', id_given_three_cls_mean(temp,:), id_given_three_cls_cov(:,:,temp)));
                       end
                   end
                end
                
                [~,cls_assignment(center_idx)] = max(posterior);
            end
        end
    end
    classified_mri = cls_assignment;
end