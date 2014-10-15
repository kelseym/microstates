% Returns a set of possible segment endpoint indices that traverse the
% range of max to min values in ordered_inflection_points
 
% A request for one segment will return a single set of indices (start & end)

% A request for two segments will return N-2 sets of endpoint where N
% is the number of inflection point indices

function segment_endpoints = find_segment_endpoints(number_of_segments, num_ordered_inflection_points, start_index)
segment_endpoints = [[]];

if num_ordered_inflection_points <= number_of_segments || number_of_segments == 0
    error('ordered_inflection_points must contain at least N+1 to find N (non-zero) segments.');
end

if number_of_segments == 1
    segment_endpoints = [[start_index num_ordered_inflection_points]];
elseif number_of_segments == 2
        % The first segment's length can vary from 1 to max
        % The second segment occupies the remaining space
        max_segment_length = num_ordered_inflection_points - number_of_segments;
        for i=1:max_segment_length
            seg1_start = start_index;
            seg1_end = start_index + i;
            seg2_end = start_index + num_ordered_inflection_points - 1;
            combined_segment = [seg1_start seg1_end seg2_end];
            segment_endpoints = [segment_endpoints; combined_segment];
        end
else
    % The ith segment can be from 1 to M - Ns long, where M is the
    % number of ordered_inflection_points and Ns is the number of regested segments
    max_segment_length = num_ordered_inflection_points - number_of_segments;
    % explore all possible lengths of the first segment
    for i=1:max_segment_length
        seg1_start = start_index;
        seg1_end = start_index + i;
        % find all combinations of segments to fill the remaining space
        tail_segments = find_segment_endpoints(number_of_segments-1, num_ordered_inflection_points-i, seg1_end);
        % combine the current first segment with each of the tail segments
        for tail=tail_segments'
            combined_segment = [seg1_start tail'];
            segment_endpoints = [segment_endpoints; combined_segment];
        end
    end
end


end