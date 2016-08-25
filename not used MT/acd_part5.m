% code for finding suitable overlap_percentile;


% Looping non-max suppression using different overlap_percentile
load('variables18Nov_before4_2.mat'); % *********


overlap_percentile_arr = [1,0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1]
acc_bub_list_length_arr = zeros(size(overlap_percentile_arr));
[~,ll] = size(overlap_percentile_arr);

tic
for idx = 1:ll

    % 4.2 Perform Non-maximum suppression to ruled out duplicates
    acc_bub_list = {}; % accepeted bubbles list

    % >>> PARAMETER: OVERLAP PERCENTILE <<<
    overlap_percentile = overlap_percentile_arr(idx); % 80% overlap - HOW DO WE DEFINE OVERLAP ?

    for pbl1 = 1:length(pot_bub_list) % for each potential bubble

        p1 = pot_bub_list{pbl1};
        overlap_bub_list = {};

        % 4.2.1 Check for overlapping region
        %  - HOW DO WE DEFINE OVERLAP * THIS IS CRUCIAL TO THE PERFORMANCE

        for pbl2 = 1:length(pot_bub_list) % check for every other bubble
            if pbl1 ~= pbl2 

                p2 = pot_bub_list{pbl2};

                % consider 3 cases, to find overlapping region
                % for x
                if p1.xcorner == p2.xcorner

                    if p1.width <= p2.width
                        del_x = p1.width;
                    else
                        del_x = p2.width;
                    end

                elseif (p1.xcorner < p2.xcorner)
                    del_x = (p1.xcorner + p1.width) - p2.xcorner;
                else
                    del_x = (p2.xcorner + p2.width) - p1.xcorner;
                end

                % for y
                if p1.ycorner == p2.ycorner
                    if p1.height <= p2.height
                        del_y = p1.height;
                    else
                        del_y = p2.height;
                    end

                elseif (p1.ycorner < p2.ycorner)
                    del_y = (p1.ycorner + p1.height) - p2.ycorner;
                else
                    del_y = (p2.ycorner + p2.height) - p1.ycorner;
                end


                % If there are some region overlapping
                if del_x > 0 && del_y > 0

                    p1area = p1.width * p1.height;
                    p2area = p2.width * p2.height;
                    avg_area = (p1area + p2area) / 2;
                    del_area = del_x * del_y;

                    % 4.2.2 see if overlapping region exceeds threshold
                    if (del_area > overlap_percentile * avg_area)
                        overlap_bub_list{length(overlap_bub_list) + 1} = p2;
                    end

                end

            end
        end

        % 4.2.3 Non-maximum suppression (sort of)

        if isempty(overlap_bub_list) % no overlap, accept it
            acc_bub_list{length(acc_bub_list)+1} = p1;
        else

            % check if p1 has opti_maxCC higher than other overlapped bubbles
            acc = 1;
            for ovl = 1:length(overlap_bub_list)
                po = overlap_bub_list{ovl};

                if p1.opti_maxCC > po.opti_maxCC
                    acc = 0;
                end
            end

            if acc == 1 % if it is, add it to accepted list
                acc_bub_list{length(acc_bub_list)+1} = p1;
            end
        end
    end

    acc_bub_list_length_arr(idx) = length(acc_bub_list); % expect it to reduce when overlap_percentile reduce

end
acc_bub_list_length_arr
