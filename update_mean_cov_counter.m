function [updated_mean, updated_cov, updated_counter] = update_mean_cov_counter(old_mean, old_cov, old_counter, intensity)
        updated_mean = old_mean + sum(intensity, 2)';
        updated_cov = old_cov + intensity*intensity';
        updated_counter = old_counter + size(intensity,2);     
end