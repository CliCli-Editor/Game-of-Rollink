
function up.get_circle_center_point(area)
    print(gameapi.get_circle_area_by_res_id(area))
    return up.actor_point(gameapi.get_circle_center_point(gameapi.get_circle_area_by_res_id(area)))
end

function up.get_rect_center_point(area)
    return up.actor_point(gameapi.get_rec_center_point(gameapi.get_rec_area_by_res_id(area)))
end
