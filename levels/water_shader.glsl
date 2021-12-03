#define DEGtoRAD 3.141592/180
number water_angle = 65*DEGtoRAD;

extern Image image2;
extern Image normal_map;
extern float d;
//extern float time;
extern number dock2_y;
extern number dock3_y;
extern number dock4_y;
extern number dock5_y;
extern number float1_y;
extern number float1_x;
extern number float2_y;
extern number float2_x;
//extern bool Debug;
number float1_x0 = 0.14166666666667;
number float2_x0 = 0.89583333333333;
number dock_y0 = 0.84;
number speed = 0.01;

/* vec4 ripples(in Image image, inout vec2 uvs, in float time, float location) {
    vec3 overlayColor = vec3(1, 1, 1);
    if (Debug) {
        overlayColor = vec3(0, 0.5, 0);
    }
    vec4 pixel = Texel(image, uvs);
    // Calculate offsets
    float xoffset = 0.001*cos(time*3.0 + 200.0*uvs.y);
    float yoffset = ((location - uvs.y)/location) * 0.02*(1.0+cos(time*3.0+100.0*uvs.y));
    pixel = Texel(image, vec2(uvs.x+xoffset, uvs.y+yoffset));
    // Adjust color
    overlayColor = overlayColor * yoffset/(((location - uvs.y)/location) * 0.02);
    // Apply if in debug mode
    if (Debug) {
        pixel = vec4(mix(pixel.rgb, overlayColor, 0.5), 1.0);
    }
    else {
        pixel = vec4(mix(pixel.rgb, overlayColor, 0.1), 1.0);
    }
    return pixel;
} */

vec4 displacement_map(in Image image, in Image normal_map, inout vec2 uvs, in float n, in bool is_canvas) {
    uvs.x -= d;
    vec4 pixel = Texel(normal_map, uvs);
    //return pixel;
    uvs.x += d;
    vec2 adjustment = (pixel.rb - vec2(0.5, 0.5))/n;
    //vec2 adjustment = 0.01*(pixel.rb - vec2(0.5, 0.5))/n;
    if (is_canvas) {
        // uvs.x = love_PixelCoord.x/love_ScreenSize.x;
        // uvs.y = love_PixelCoord.y/love_ScreenSize.y;
        // adjustment.x = adjustment.x/love_ScreenSize.x;
        // adjustment.y = adjustment.x/love_ScreenSize.y;
    }
    float avg_color = (pixel.r + pixel.g + pixel.b)/3.0;
    pixel = Texel(image, uvs+adjustment);
    //return pixel * vec4(uvs.y, 0, 0, 1);
    // return pixel;
    vec4 new_color = vec4(1.0, 1.0, 1.0, 1.0);
    if (n > 0) {
        new_color = vec4(pixel.r/avg_color, pixel.g/avg_color, 0.7, 1.0);
    }
    return pixel * new_color;
}

vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords) {

    number ux = uvs.x;
    number uy = uvs.y;
    number dx_float1 = float1_x - float1_x0;
    number dx_float2 = float2_x - float2_x0;
    number dy1 = 0.0095;
    number dy2 = 0.06;
    number n = 20;
    vec4 pixel = Texel(image, uvs); // unaltered pixel

    // Patch 1
    number x1 = 0;
    number x2 = 0.0729 + dx_float1;
    number y1 = float1_y + 0.01;
    number y2 = 0;
    if (ux > x1 && ux < x2) {
        if(uy > dock_y0) {
            uy = dock_y0 - dy2 - (uy - dock_y0) ;//* tan(water_angle);
            uvs = vec2(ux, uy);
            pixel = displacement_map(image, normal_map, uvs, n, bool(false));
        }
        else {
            pixel = displacement_map(image2, normal_map, uvs, n, bool(true));
        }
        
        //return vec4(0.0, 0.5, 0.0, 0.7);
    }
    // Patch 2
    x1 = 0.0729 + dx_float1;
    x2 = 0.2083 + dx_float1;
    y1 = float1_y + 0.01;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            if (uy < y1 + dy1) {
                uy = y1 - (uy - dock_y0) ;//* tan(water_angle);
                uvs = vec2(ux, uy);
                pixel = Texel(image, uvs);
            }
            else {
                uy = dock_y0 - dy2 - (uy - dock_y0) ;//* tan(water_angle);
                uvs = vec2(ux, uy);
                pixel = displacement_map(image, normal_map, uvs, n, bool(false));
            }
            //return vec4(0.0, 0.5, 0.0, 0.7);
        }
        else {
            pixel = displacement_map(image2, normal_map, uvs, n, bool(true));
        }
    }
    // Patch 3
    x1 = 0.2083 + dx_float1;
    x2 = 0.2640;
    y1 = float1_y + 0.01;
    if (ux > x1 && ux < x2) {
        if(uy > dock_y0) {
            uy = dock_y0 - dy2 - (uy - dock_y0) ;//* tan(water_angle);
            uvs = vec2(ux, uy);
            pixel = displacement_map(image, normal_map, uvs, n, bool(false));
        }
        else {
            pixel = displacement_map(image2, normal_map, uvs, n, bool(true));
        }
        //return vec4(0.0, 0.5, 0.0, 0.7);
    }
    // Patch 4
    x1 =  0.2640;
    x2 = 0.3222;
    y1 = dock2_y + 0.01;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            if (uy < y1 + dy1) {
                uy = y1 - (uy - y1) ;//* tan(water_angle);
                uvs = vec2(ux, uy);
                pixel = Texel(image, uvs);
            }
            else {
                uy = dock_y0 - dy2 - (uy - dock_y0) ;//* tan(water_angle);
                uvs = vec2(ux, uy);
                pixel = displacement_map(image, normal_map, uvs, n, bool(false));
            }
        }
        else {
            pixel = displacement_map(image2, normal_map, uvs, n, bool(true));
        }
            //return vec4(0.0, 0.5, 0.0, 0.7);
    }
    // Patch 5
    x1 =  0.3222;
    x2 = 0.4167;
    y1 = dock3_y + 0.01;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            if (uy < y1 + dy1) {
                uy = y1 - (uy - y1) ;//* tan(water_angle);
                uvs = vec2(ux, uy);
                pixel = Texel(image, uvs);
            }
            else {
                uy = dock_y0 - dy2 - (uy - dock_y0) ;//* tan(water_angle);
                uvs = vec2(ux, uy);
                pixel = displacement_map(image, normal_map, uvs, n, bool(false));
            }
            //return vec4(0.0, 0.5, 0.0, 0.7);
        }
        else {
            pixel = displacement_map(image2, normal_map, uvs, n, bool(true));
        }
    }
    // Middle Patch
    x1 =  0.4167;
    x2 = 0.5868;
    y1 = dock_y0;
    if (ux > x1 && ux < x2) {
        if(uy < y1) {
            pixel = displacement_map(image2, normal_map, uvs, n, bool(true));
        }
            //return vec4(0.0, 0.5, 0.0, 0.7);
    }
    // Patch 6
    x1 =  0.5868;
    x2 = 0.6840;
    y1 = dock4_y + 0.01;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            if (uy < y1 + dy1) {
                uy = y1 - (uy - y1) ;//* tan(water_angle);
                uvs = vec2(ux, uy);
                pixel = Texel(image, uvs);
            }
            else {
                uy = dock_y0 - dy2 - (uy - dock_y0) ;//* tan(water_angle);
                uvs = vec2(ux, uy);
                pixel = displacement_map(image, normal_map, uvs, n, bool(false));
            }
            //return vec4(0.0, 0.5, 0.0, 0.7);
        }
        else {
            pixel = displacement_map(image2, normal_map, uvs, n, bool(true));
        }
    }
    // Patch 7
    x1 =  0.6840;
    x2 = 0.7465;
    y1 = dock5_y + 0.01;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            if (uy < y1 + dy1) {
                uy = y1 - (uy - y1) ;//* tan(water_angle);
                uvs = vec2(ux, uy);
                pixel = Texel(image, uvs);
            }
            else {
                uy = dock_y0 - dy2 - (uy - dock_y0) ;//* tan(water_angle);
                uvs = vec2(ux, uy);
                pixel = displacement_map(image, normal_map, uvs, n, bool(false));
            }
            //return vec4(0.0, 0.5, 0.0, 0.7);
        }
        else {
            pixel = displacement_map(image2, normal_map, uvs, n, bool(true));
        }
    }
    // Patch 8
    x1 = 0.7465;
    x2 = 0.8264 + dx_float2;
    y1 = dock5_y + 0.01;
    //y1 = float2_y + 0.025;
    if (ux > x1 && ux < x2) {
        if(uy > dock_y0) {
            uy = dock_y0 - dy2 - (uy - dock_y0) ;//* tan(water_angle);
            uvs = vec2(ux, uy);
            pixel = displacement_map(image, normal_map, uvs, n, bool(false));
            //return vec4(0.0, 0.5, 0.0, 0.7);
        } else {
            // return vec4(0.0, 0.5, 0.0, 0.7);
            pixel = displacement_map(image2, normal_map, uvs, n, bool(true));
        }
        
    }
    // Patch 9
    x1 = 0.8264 + dx_float2;
    //x2 = 0.9757 + dx_float2;
    x2 = 0.8264 + dx_float2 + 0.07;
    y1 = float2_y + 0.025;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            if (uy < y1 + dy1) {
                uy = y1 - (uy - y1) ;//* tan(water_angle);
                uvs = vec2(ux, uy);
                pixel = Texel(image, uvs);
            }
            else {
                uy = dock_y0 - dy2 - (uy - dock_y0) ;//* tan(water_angle);
                uvs = vec2(ux, uy);
                pixel = displacement_map(image, normal_map, uvs, n, bool(false));
            }
            //return vec4(0.0, 0.5, 0.0, 0.7);
        }
        else {
            pixel = displacement_map(image2, normal_map, uvs, n, bool(true));
            // pixel = displacement_map(image2, normal_map, uvs, n, bool(true));
        }
    }
    // Patch 10
    x1 = 0.8264 + dx_float2 + 0.07;
    x2 = 0.9757 + dx_float2;
    y1 = float2_y + 0.025;
    if (ux > x1 && ux < x2) {
        if(uy > y1) {
            if (uy < y1 + dy1 + ((0.1/(x2-x1))*(ux-x1)) ) {
                uy = y1 - (uy - y1) ;//* tan(water_angle);
                uvs = vec2(ux, uy);
                pixel = displacement_map(image, normal_map, uvs, 100, bool(true));
            }
            else {
                uy = dock_y0 - dy2 - (uy - dock_y0) ;//* tan(water_angle);
                uvs = vec2(ux, uy);
                pixel = displacement_map(image, normal_map, uvs, n, bool(false));
            }
            //return vec4(0.5, 0.5, 0.0, 0.7);
        }
        else {
            pixel = displacement_map(image2, normal_map, uvs, n, bool(true));
        }
    }
    // Patch 11
    x1 = 0.9757 + dx_float2;
    x2 = 1.0;
    y1 = float2_y + 0.025;
    if (ux > x1 && ux < x2) {
        if(uy > dock_y0) {
            uy = dock_y0 - dy2 - (uy - dock_y0) ;//* tan(water_angle);
            uvs = vec2(ux, uy);
            pixel = displacement_map(image, normal_map, uvs, n, bool(false));
        } else {
            pixel = displacement_map(image2, normal_map, uvs, n, bool(true));
        }
        
        //return vec4(0.0, 0.5, 0.0, 0.7);
    }

        
    return pixel * color;
}