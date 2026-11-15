# SKILL: Modelado procedural de figuras humanas 3D con Three.js

## Objetivo

Desarrollar modelos tridimensionales de cuerpos humanos utilizando exclusivamente geometrías primitivas de Three.js, como esferas, cilindros, cápsulas, conos y cajas.

El objetivo es construir un cuerpo humano reconocible, proporcionado, articulado y visualmente atractivo sin depender inicialmente de modelos externos (.glb, .gltf, .fbx).

## 1\. Construcción del cuerpo humano

Representar cada parte del cuerpo mediante geometrías 3D:

- Cabeza: esfera o geometría elipsoidal.
- Cuello: cilindro.
- Torso: combinación de cajas, cápsulas y esferas.
- Pelvis: caja o esfera escalada.
- Hombros: esferas.
- Brazos: cilindros o cápsulas.
- Codos: esferas.
- Antebrazos: cilindros o cápsulas.
- Muñecas: esferas pequeñas.
- Manos: combinación de geometrías.
- Muslos: cilindros o cápsulas.
- Rodillas: esferas.
- Pantorrillas: cilindros o cápsulas.
- Tobillos: esferas.
- Pies: cajas o geometrías personalizadas.

## 2\. Proporciones anatómicas

Utilizar proporciones humanas coherentes:

- Altura total: aproximadamente 7.5 a 8 cabezas.
- Cabeza: 1 unidad de referencia.
- Torso: proporcional al tamaño de la cabeza.
- Brazos: longitud anatómica natural.
- Piernas: aproximadamente la mitad de la altura total.
- Manos y pies: dimensiones proporcionadas.

Evitar extremidades demasiado delgadas, articulaciones desalineadas y cuerpos excesivamente rígidos.

## 3\. Articulaciones y jerarquía

Crear una estructura jerárquica mediante THREE.Group().

Organizar el modelo de la siguiente manera:

Human

- Head
- Neck
- Torso
- Pelvis
- LeftArm
  - Shoulder
  - UpperArm
  - Elbow
  - Forearm
  - Hand
- RightArm
  - Shoulder
  - UpperArm
  - Elbow
  - Forearm
  - Hand
- LeftLeg
  - Hip
  - Thigh
  - Knee
  - Shin
  - Foot
- RightLeg
  - Hip
  - Thigh
  - Knee
  - Shin
  - Foot

Las extremidades deben permitir rotaciones independientes desde sus articulaciones.

## 4\. Requisitos técnicos de Three.js

- Utilizar THREE.Scene.
- Utilizar THREE.PerspectiveCamera.
- Utilizar THREE.WebGLRenderer.
- Utilizar THREE.MeshStandardMaterial.
- Utilizar THREE.Group para organizar las partes anatómicas.
- Utilizar geometrías primitivas optimizadas.
- Implementar iluminación ambiental y direccional.
- Incorporar OrbitControls para inspeccionar el modelo desde cualquier ángulo.
- Implementar sombras cuando sea posible.
- Mantener el código modular y reutilizable.

## 5\. Calidad visual

El modelo debe:

- Tener apariencia tridimensional real.
- Mantener simetría anatómica.
- Evitar que las geometrías queden desconectadas.
- Evitar huecos visibles entre las articulaciones.
- Utilizar materiales coherentes y una paleta de colores uniforme.
- Permitir visualizar el cuerpo desde diferentes perspectivas.

## 6\. Funcionalidades adicionales

Preparar la arquitectura para incorporar:

- Movimiento de brazos y piernas.
- Rotación de articulaciones.
- Animaciones de caminar.
- Diferentes poses humanas.
- Control individual de extremidades.
- Selección de partes del cuerpo mediante raycasting.
- Modificación dinámica de proporciones.

## 7\. Instrucción de implementación

Antes de programar, analiza la estructura del proyecto existente y respeta su arquitectura, dependencias y convenciones.

No reemplaces funcionalidades existentes innecesariamente.

Implementa el modelo humano 3D de forma modular, con geometrías reutilizables y una jerarquía de articulaciones preparada para futuras animaciones.

El resultado debe ser un cuerpo humano completo, reconocible, proporcionado y manipulable en un espacio tridimensional.