#pragma once

#include "imgui/imgui.h"

constexpr float room_size = 15.f;
constexpr float max_shininess = 127.f;

using vec4f = float[4];

/**
 * @brief Material properties
 *
 */
struct Material {
    /// Ambient color of the object
    vec4f ambient{};
    /// Diffuse color of the object
    vec4f diffuse{};
    /// Specular color of the object
    vec4f specular{};
    /// Shininess of the object
    float shininess{.0f};
};

/**
 * @brief Light properties
 *
 */
struct Light {
    /// Ambient color of the light
    vec4f ambient{};
    /// Diffuse color of the light
    vec4f diffuse{};
    /// Specular color of the light
    vec4f specular{};
    /// Position of the light
    vec4f position{};
    /// Whether the light is directional
    bool directional{false};
};