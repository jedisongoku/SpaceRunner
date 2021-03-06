// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Battlehub/Legacy Shaders/Lightmapped/HB_VertexLit" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_LightMap ("Lightmap (RGB)", 2D) = "lightmap" { LightmapMode }

}

SubShader {
	LOD 100
	Tags { "RenderType"="Opaque" }

	Pass {
		Name "BASE"
		Tags {"LightMode" = "Vertex"}
		Lighting On

		CGPROGRAM
		#include "../../CGIncludes/HB_Core.cginc"
		
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_fog
		#include "UnityCG.cginc"

		struct v2f {
			float2 uv : TEXCOORD0;
			float2 uv2 : TEXCOORD1;
			UNITY_FOG_COORDS(2)
			fixed4 diff : COLOR0;
			float4 pos : SV_POSITION;
		};

		uniform float4 _MainTex_ST;
		uniform float4 _LightMap_ST;
		uniform float4 _Color;

		struct appdata_base_2 {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
			float4 texcoord1 : TEXCOORD1;
		};

		v2f vert(appdata_base_2 v)
		{
			v2f o;
			
			HB(v.vertex)
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
			o.uv2 = TRANSFORM_TEX(v.texcoord1, _LightMap);

			float4 diffuse = float4(ShadeVertexLightsFull(v.vertex, v.normal, 4, true), 1.0f);
			o.diff = diffuse * _Color;

			UNITY_TRANSFER_FOG(o,o.pos);
			return o;
		}	

		uniform sampler2D _MainTex;
		uniform sampler2D _LightMap;

		fixed4 frag(v2f i) : SV_Target
		{
			fixed4 tx = tex2D(_MainTex, i.uv);
			fixed4 lm = tex2D(_LightMap, i.uv2);
			fixed4 c =  tx * (lm *  _Color  + i.diff);
	
			UNITY_APPLY_FOG(i.fogCoord, c);
			UNITY_OPAQUE_ALPHA(c.a);
			return c;
		}
		ENDCG
	}
}

Fallback "Battlehub/Legacy Shaders/HB_VertexLit"


}
