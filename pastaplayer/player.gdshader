shader_type canvas_item;

uniform vec4 silhouette_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Cor da silhueta
uniform float fade_speed = 1.0; // Velocidade de desaparecimento

void fragment() {
    // Obtenha as coordenadas UV
	vec2 uv = UV;
    
    //Calcule a distância do centro (para criar um gradiente circular)
	float distance_from_center = length(uv - vec2(0.5));
    
    // Controle da transparência com base na distância
	float alpha = smoothstep(0.4, 0.5, distance_from_center);
    
    // Misture a cor original com a cor da silhueta
	COLOR = mix(COLOR, silhouette_color, alpha * fade_speed);
}
