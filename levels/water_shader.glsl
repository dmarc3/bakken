#define DEGtoRAD 3.141592/180
number water_angle = 65*DEGtoRAD;

extern number dock2_y;
extern number dock3_y;
extern number dock4_y;
extern number dock5_y;
extern number float1_y;
extern number float1_x;
number float1_x0 = 0.14166666666667;
extern number float2_y;
extern number float2_x;
number float2_x0 = 0.89583333333333;

vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords) {

    number ux = uvs.x;
    number uy = uvs.y;
    number dx_float1 = float1_x - float1_x0;
    number dx_float2 = float2_x - float2_x0;
    number dy1 = 0.015;
    number dy2 = 0.06;
    number color_correction = 1.0;
    
    // Patch 1
    number x1 = 0;
    number x2 = 0.0729 + dx_float1;
    number y1 = float1_y + 0.02;
    number y2 = 0;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            uy = y1 - dy2 - (uy - y1) * tan(water_angle);
            color_correction = (0.8)/(1-0.83)*(uy-0.83);
            //return vec4(0.0, 0.5, 0.0, 1.0);
        }
    }
    // Patch 2
    x1 = 0.0729 + dx_float1;
    x2 = 0.2083 + dx_float1;
    y1 = float1_y + 0.02;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            if (uy < y1 + dy1) {
                uy = y1 - (uy - y1) * tan(water_angle);
            }
            else {
                uy = y1 - dy2 - (uy - y1) * tan(water_angle);
            }
            //return vec4(0.0, 0.5, 0.0, 1.0);
        }
    }
    // Patch 3
    x1 = 0.2083 + dx_float1;
    x2 = 0.2640;
    y1 = float1_y + 0.02;
    y2 = dock2_y + 0.01;
    if (ux > x1 && ux < x2) {
        if(uy > y1 + (y1-y2)/(x1-x2)*(ux-x1)) {
            uy = y1 - dy2 - (uy - y1) * tan(water_angle);
            //return vec4(0.0, 0.5, 0.0, 1.0);
        }
    }
    // Patch 4
    x1 =  0.2640;
    x2 = 0.3222;
    y1 = dock2_y + 0.01;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            if (uy < y1 + dy1) {
                uy = y1 - (uy - y1) * tan(water_angle);
            }
            else {
                uy = y1 - dy2 - (uy - y1) * tan(water_angle);
            }
            //return vec4(0.0, 0.5, 0.0, 1.0);
        }
    }
    // Patch 5
    x1 =  0.3222;
    x2 = 0.4167;
    y1 = dock3_y + 0.01;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            if (uy < y1 + dy1) {
                uy = y1 - (uy - y1) * tan(water_angle);
            }
            else {
                uy = y1 - dy2 - (uy - y1) * tan(water_angle);
            }
            //return vec4(0.0, 0.5, 0.0, 1.0);
        }
    }
    // Patch 6
    x1 =  0.5868;
    x2 = 0.6840;
    y1 = dock4_y + 0.01;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            if (uy < y1 + dy1) {
                uy = y1 - (uy - y1) * tan(water_angle);
            }
            else {
                uy = y1 - dy2 - (uy - y1) * tan(water_angle);
            }
            //return vec4(0.0, 0.5, 0.0, 1.0);
        }
    }
    // Patch 7
    x1 =  0.6840;
    x2 = 0.7465;
    y1 = dock5_y + 0.01;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            if (uy < y1 + dy1) {
                uy = y1 - (uy - y1) * tan(water_angle);
            }
            else {
                uy = y1 - dy2 - (uy - y1) * tan(water_angle);
            }
            //return vec4(0.0, 0.5, 0.0, 1.0);
        }
    }
    // Patch 8
    x1 = 0.7465;
    x2 = 0.8264 + dx_float2;
    y1 = dock5_y + 0.01;
    y2 = float2_y + 0.02;
    if (ux > x1 && ux < x2) {
        if(uy > y1 + (y1-y2)/(x1-x2)*(ux-x1)) {
            uy = y1 - dy2 - (uy - y1) * tan(water_angle);
            //return vec4(0.0, 0.5, 0.0, 1.0);
        }
    }
    // Patch 9
    x1 = 0.8264 + dx_float2;
    x2 = 0.9757 + dx_float2;
    y1 = float2_y + 0.02;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            if (uy < y1 + dy1) {
                uy = y1 - (uy - y1) * tan(water_angle);
            }
            else {
                uy = y1 - dy2 - (uy - y1) * tan(water_angle);
            }
            //return vec4(0.0, 0.5, 0.0, 1.0);
        }
    }
    // Patch 10
    x1 = 0.9757 + dx_float2;
    x2 = 1.0;
    y1 = float2_y + 0.02;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            if (uy < y1 + dy1) {
                uy = y1 - (uy - y1) * tan(water_angle);
            }
            else {
                uy = y1 - dy2 - (uy - y1) * tan(water_angle);
            }
            //return vec4(0.0, 0.5, 0.0, 1.0);
        }
    }
    vec2 final_coord = vec2(ux, uy);
    vec4 pixel = Texel(image, final_coord);
    //color[3] = color_correction;
    return pixel * color;
}