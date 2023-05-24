
#define USE_PBR

#include <common_frag>
#include <dithering_pars_frag>

// if no light> this will not active
uniform float u_Metalness;
#ifdef USE_METALNESSMAP
	uniform sampler2D metalnessMap;
#endif

uniform float u_Roughness;
#ifdef USE_ROUGHNESSMAP
	uniform sampler2D roughnessMap;
#endif

uniform float specularFactor; // Modification : add specular factor

uniform vec3 emissive;

#include <uv_pars_frag>
#include <color_pars_frag>
#include <diffuseMap_pars_frag>
#include <alphamap_pars_frag>
#include <normalMap_pars_frag>
#include <bumpMap_pars_frag>
#include <envMap_pars_frag>
#include <aoMap_pars_frag>
#include <light_pars_frag>
#include <normal_pars_frag>
#include <modelPos_pars_frag>
#include <bsdfs>
#include <shadowMap_pars_frag>
#include <fog_pars_frag>
#include <emissiveMap_pars_frag>
#include <logdepthbuf_pars_frag>
#include <clippingPlanes_pars_frag>

#ifdef COLOR_MAPPING
  uniform sampler2D colorMapping;
  uniform float colorMappingIntensity;
#endif

void main() {
    #include <clippingPlanes_frag>
    #include <logdepthbuf_frag>
    #include <begin_frag>
    #include <color_frag>
    #include <diffuseMap_frag>
	#include <alphamap_frag>
	
#ifdef COLOR_MAPPING
  float gray = clamp( dot( outColor.rgb, vec3(0.333, 0.333, 0.333) ), 0.0, 1.0 );
  outColor.rgb = mix( outColor.rgb, texture2D( colorMapping, vec2( gray, 0.5 ) ).rgb, colorMappingIntensity );
#endif

    #include <alphaTest_frag>
    #include <normal_frag>

    float roughnessFactor = u_Roughness;
    #ifdef USE_ROUGHNESSMAP
    	vec4 texelRoughness = texture2D( roughnessMap, v_Uv );
    	// reads channel G, compatible with a combined OcclusionRoughnessMetallic (RGB) texture
    	roughnessFactor *= texelRoughness.g;
    #endif

    float metalnessFactor = u_Metalness;
    #ifdef USE_METALNESSMAP
    	vec4 texelMetalness = texture2D( metalnessMap, v_Uv );
    	// reads channel B, compatible with a combined OcclusionRoughnessMetallic (RGB) texture
    	metalnessFactor *= texelMetalness.b;
    #endif

	ReflectedLight reflectedLight = ReflectedLight(vec3(0.0), vec3(0.0), vec3(0.0), vec3(0.0));
	
// Use v_modelPos from modelPos_pars_frag
// Use geometryNormal, N from normal_frag

#ifdef USE_LIGHT

    #ifdef USE_PBR
        #ifdef USE_PBR2
            vec3 diffuseColor = outColor.xyz;
            vec3 specularColor = specularFactor.xyz;
			float roughness = max(1.0 - glossinessFactor, 0.0525);
        #else
            vec3 diffuseColor = outColor.xyz * (1.0 - metalnessFactor);
            vec3 specularColor = mix(vec3(0.04), outColor.xyz, metalnessFactor);
            float roughness = max(roughnessFactor, 0.0525);
        #endif

        vec3 dxy = max(abs(dFdx(geometryNormal)), abs(dFdy(geometryNormal)));
        float geometryRoughness = max(max(dxy.x, dxy.y), dxy.z);
        roughness += geometryRoughness;

        roughness = min(roughness, 1.0);
    #else
        vec3 diffuseColor = outColor.xyz;
        #ifdef USE_PHONG
            vec3 specularColor = u_SpecularColor.xyz;
            float shininess = u_Specular;
        #endif
    #endif

    #if (defined(USE_PHONG) || defined(USE_PBR))
        vec3 V = normalize(u_CameraPosition - v_modelPos);
    #endif

    vec3 L;
    float falloff;
    float dotNL;
    vec3 irradiance;

    #if NUM_DIR_LIGHTS > 0

        #pragma unroll_loop_start
        for (int i = 0; i < NUM_DIR_LIGHTS; i++) {
            L = normalize(-u_Directional[i].direction);
            falloff = 1.0;

            #if defined(USE_SHADOW) && (UNROLLED_LOOP_INDEX < NUM_DIR_SHADOWS)
                #ifdef USE_PCSS_SOFT_SHADOW
                    falloff *= getShadowWithPCSS(directionalDepthMap[i], directionalShadowMap[i], vDirectionalShadowCoord[i], u_DirectionalShadow[i].shadowMapSize, u_DirectionalShadow[i].shadowBias, u_DirectionalShadow[i].shadowParams);
                #else
                    falloff *= getShadow(directionalShadowMap[i], vDirectionalShadowCoord[i], u_DirectionalShadow[i].shadowMapSize, u_DirectionalShadow[i].shadowBias, u_DirectionalShadow[i].shadowParams);
                #endif
            #endif

            dotNL = saturate(dot(N, L));
            irradiance = u_Directional[i].color * falloff * dotNL * PI;

            reflectedLight.directDiffuse += irradiance * BRDF_Diffuse_Lambert(diffuseColor);

            #ifdef USE_PHONG
                reflectedLight.directSpecular += irradiance * BRDF_Specular_BlinnPhong(specularColor, N, L, V, shininess) * specularStrength;
            #endif

            #ifdef USE_PBR
                reflectedLight.directSpecular += specularFactor * irradiance * BRDF_Specular_GGX(specularColor, N, L, V, roughness);    // Modification : add specular factor
            #endif
        }
        #pragma unroll_loop_end
    #endif

    #if NUM_POINT_LIGHTS > 0
        vec3 worldV;

        #pragma unroll_loop_start
        for (int i = 0; i < NUM_POINT_LIGHTS; i++) {
            worldV = v_modelPos - u_Point[i].position;

            L = -worldV;
            falloff = pow(clamp(1. - length(L) / u_Point[i].distance, 0.0, 1.0), u_Point[i].decay);
            L = normalize(L);

            #if defined(USE_SHADOW) && (UNROLLED_LOOP_INDEX < NUM_POINT_SHADOWS)
                falloff *= getPointShadow(pointShadowMap[i], vPointShadowCoord[i], u_PointShadow[i].shadowMapSize, u_PointShadow[i].shadowBias, u_PointShadow[i].shadowParams, u_PointShadow[i].shadowCameraRange);
            #endif

            dotNL = saturate(dot(N, L));
            irradiance = u_Point[i].color * falloff * dotNL * PI;

            reflectedLight.directDiffuse += irradiance * BRDF_Diffuse_Lambert(diffuseColor);

            #ifdef USE_PHONG
                reflectedLight.directSpecular += irradiance * BRDF_Specular_BlinnPhong(specularColor, N, L, V, shininess) * specularStrength;
            #endif

            #ifdef USE_PBR
                reflectedLight.directSpecular += specularFactor * irradiance * BRDF_Specular_GGX(specularColor, N, L, V, roughness);    // Modification : add specular factor
            #endif
        }
        #pragma unroll_loop_end
    #endif

    #if NUM_SPOT_LIGHTS > 0
        float lightDistance;
        float angleCos;

        #pragma unroll_loop_start
        for (int i = 0; i < NUM_SPOT_LIGHTS; i++) {
            L = u_Spot[i].position - v_modelPos;
            lightDistance = length(L);
            L = normalize(L);
            angleCos = dot(L, -normalize(u_Spot[i].direction));

            falloff = smoothstep(u_Spot[i].coneCos, u_Spot[i].penumbraCos, angleCos);
            falloff *= pow(clamp(1. - lightDistance / u_Spot[i].distance, 0.0, 1.0), u_Spot[i].decay);

            #if defined(USE_SHADOW) && (UNROLLED_LOOP_INDEX < NUM_SPOT_SHADOWS)
                #ifdef USE_PCSS_SOFT_SHADOW
                    falloff *= getShadowWithPCSS(spotDepthMap[i], spotShadowMap[i], vSpotShadowCoord[i], u_SpotShadow[i].shadowMapSize, u_SpotShadow[i].shadowBias, u_SpotShadow[i].shadowParams);
                #else
                    falloff *= getShadow(spotShadowMap[i], vSpotShadowCoord[i], u_SpotShadow[i].shadowMapSize, u_SpotShadow[i].shadowBias, u_SpotShadow[i].shadowParams);
                #endif
            #endif

            dotNL = saturate(dot(N, L));
            irradiance = u_Spot[i].color * falloff * dotNL * PI;

            reflectedLight.directDiffuse += irradiance * BRDF_Diffuse_Lambert(diffuseColor);

            #ifdef USE_PHONG
                reflectedLight.directSpecular += irradiance * BRDF_Specular_BlinnPhong(specularColor, N, L, V, shininess) * specularStrength;
            #endif

            #ifdef USE_PBR
                reflectedLight.directSpecular += specularFactor * irradiance * BRDF_Specular_GGX(specularColor, N, L, V, roughness);    // Modification : add specular factor
            #endif
        }
        #pragma unroll_loop_end
    #endif

    vec3 iblIrradiance = vec3(0., 0., 0.);
    vec3 indirectIrradiance = vec3(0., 0., 0.);
    vec3 indirectRadiance = vec3(0., 0., 0.);

    #ifdef USE_AMBIENT_LIGHT
        indirectIrradiance += u_AmbientLightColor * PI;
    #endif

    #if NUM_HEMI_LIGHTS > 0
        float hemiDiffuseWeight;

        #pragma unroll_loop_start
        for (int i = 0; i < NUM_HEMI_LIGHTS; i++) {
            L = normalize(u_Hemi[i].direction);

            dotNL = dot(N, L);
            hemiDiffuseWeight = 0.5 * dotNL + 0.5;

            indirectIrradiance += mix(u_Hemi[i].groundColor, u_Hemi[i].skyColor, hemiDiffuseWeight) * PI;
        }
        #pragma unroll_loop_end
    #endif

    // TODO light map

    #if defined(USE_ENV_MAP) && defined(USE_PBR)
        vec3 envDir;
        #ifdef USE_VERTEX_ENVDIR
            envDir = v_EnvDir;
        #else
            envDir = reflect(normalize(v_modelPos - u_CameraPosition), N);
        #endif
        iblIrradiance += getLightProbeIndirectIrradiance(maxMipLevel, N);
        indirectRadiance += getLightProbeIndirectRadiance(GGXRoughnessToBlinnExponent(roughness), maxMipLevel, envDir);
    #endif

    reflectedLight.indirectDiffuse += indirectIrradiance * BRDF_Diffuse_Lambert(diffuseColor);

    #if defined(USE_ENV_MAP) && defined(USE_PBR)
        // reflectedLight.indirectSpecular += indirectRadiance * BRDF_Specular_GGX_Environment(N, V, specularColor, roughness);

        float clearcoatDHR = 0.0; // TODO for clearcoat

        float clearcoatInv = 1.0 - clearcoatDHR;

        // Both indirect specular and indirect diffuse light accumulate here

        vec3 singleScattering = vec3(0.0);
	    vec3 multiScattering = vec3(0.0);

        vec3 cosineWeightedIrradiance = iblIrradiance * RECIPROCAL_PI;

        BRDF_Specular_Multiscattering_Environment(N, V, specularColor, roughness, singleScattering, multiScattering);

        vec3 diffuse = diffuseColor * (1.0 - (singleScattering + multiScattering));

        reflectedLight.indirectSpecular += clearcoatInv * indirectRadiance * singleScattering;
        reflectedLight.indirectSpecular += multiScattering * cosineWeightedIrradiance;

        reflectedLight.indirectDiffuse += diffuse * cosineWeightedIrradiance;
    #endif

#endif

	#ifndef USE_LIGHT
		float roughness = max(roughnessFactor, 0.0525);
		vec3 dxy = max(abs(dFdx(geometryNormal)), abs(dFdy(geometryNormal)));
		float geometryRoughness = max(max(dxy.x, dxy.y), dxy.z);
		roughness += geometryRoughness;
		vec3 V = normalize(u_CameraPosition - v_modelPos);
	#endif
	
#ifdef SIMULATE_BASIC
    reflectedLight.indirectDiffuse += vec3(1.0);
#endif

	#include <aoMap_frag>
    
#ifdef SIMULATE_BASIC
    reflectedLight.indirectDiffuse *= outColor.xyz;
    outColor.xyz = reflectedLight.indirectDiffuse;
#else
    outColor.xyz = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular;
#endif

    
    #include <shadowMap_frag>

    vec3 totalEmissiveRadiance = emissive;
	
#ifdef USE_EMISSIVEMAP

	vec4 emissiveColor = texture2D(emissiveMap, vEmissiveMapUV);

	emissiveColor.rgb = emissiveMapTexelToLinear( emissiveColor ).rgb;

	totalEmissiveRadiance *= emissiveColor.rgb;

	#ifdef USE_PBR
		#ifdef USE_SIDE_EMISSIVE
			vec3 emissiveUp = vec3(0., 1., 0.);

			totalEmissiveRadiance.rgb *= totalEmissiveRadiance.rgb * (1. - abs(dot(v_Normal, emissiveUp)));
		#endif
	#endif

#endif

    outColor.xyz += totalEmissiveRadiance;

    #include <end_frag>
    #include <encodings_frag>
    #include <premultipliedAlpha_frag>
    #include <fog_frag>
    #include <dithering_frag>
}



#define USE_PBR

#include <common_vert>
#include <normal_pars_vert>

#if defined(USE_UV1) || defined(USE_UV2)
    uniform mat3 uvTransform;
#endif

#ifdef USE_UV1
    attribute vec2 a_Uv;
    varying vec2 v_Uv;
#endif

#ifdef USE_UV2
    attribute vec2 a_Uv2;
    varying vec2 v_Uv2;
#endif

#ifdef USE_UV3
    attribute vec2 a_Uv3;
#endif

#include <color_pars_vert>
#include <modelPos_pars_vert>
#include <envMap_pars_vert>
#include <aoMap_pars_vert>
#include <alphamap_pars_vert>
#include <emissiveMap_pars_vert>
#include <shadowMap_pars_vert>
#include <morphtarget_pars_vert>
#include <skinning_pars_vert>
#include <logdepthbuf_pars_vert>

#ifdef USE_INSTANCING
	
	attribute mat4 instanceMatrix;

	#if defined(USE_VCOLOR_RGB) || defined(USE_VCOLOR_RGBA)
		// attribute vec3 instanceColor;
	#endif
	
#endif

void main() {
    #include <begin_vert>
    #include <morphtarget_vert>
    #include <morphnormal_vert>
    #include <skinning_vert>
    #include <skinnormal_vert>
	
#ifdef USE_INSTANCING
	transformed.xyz = ( instanceMatrix * vec4( transformed, 1.0 ) ).xyz;
#endif

    #include <pvm_vert>
	
#ifdef USE_INSTANCING
	mat3 im = mat3( instanceMatrix );
	objectNormal /= vec3( dot( im[ 0 ], im[ 0 ] ), dot( im[ 1 ], im[ 1 ] ), dot( im[ 2 ], im[ 2 ] ) );
	objectNormal = im * objectNormal;
#endif

    #include <normal_vert>
    #include <logdepthbuf_vert>
    #include <uv_vert>
    #include <color_vert>
	
#ifdef USE_INSTANCING
	#if defined(USE_VCOLOR_RGB) || defined(USE_VCOLOR_RGBA)

		// v_Color.xyz = instanceColor.xyz;
		// v_Color.xyz *= instanceColor.xyz;

	#endif
#endif

    #include <modelPos_vert>
    #include <envMap_vert>
    #include <aoMap_vert>
	
#ifdef USE_ALPHA_MAP

	#if (USE_ALPHA_MAP == 2)
        vAlphaMapUV = (alphaMapUVTransform * vec3(a_Uv2, 1.)).xy;
    #elif (USE_ALPHA_MAP == 3)
        vAlphaMapUV = (alphaMapUVTransform * vec3(a_Uv3, 1.)).xy;
    #else
        vAlphaMapUV = (alphaMapUVTransform * vec3(a_Uv, 1.)).xy;
    #endif

#endif

	
#ifdef USE_EMISSIVEMAP
	#if (USE_EMISSIVEMAP == 2)
		vEmissiveMapUV = (emissiveMapUVTransform * vec3(a_Uv2, 1.)).xy;
    #elif (USE_EMISSIVEMAP == 3)
        vEmissiveMapUV = (emissiveMapUVTransform * vec3(a_Uv3, 1.)).xy;
	#else
		vEmissiveMapUV = (emissiveMapUVTransform * vec3(a_Uv, 1.)).xy;
	#endif
#endif

    #include <shadowMap_vert>
}
