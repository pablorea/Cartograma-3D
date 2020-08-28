/*  This file is part of C3D.

    C3D is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    C3D is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with C3D.  If not, see <https://www.gnu.org/licenses/>.  */

import processing.dxf.*;
import peasy.*;
import peasy.PeasyCam;
import processing.opengl.PGL;
import processing.opengl.PGraphics3D;
import processing.opengl.PJOGL;

Datos datos;
Mapa[] mapas = new Mapa[2];

int cantMapas = 1;
int separacion = 2;
String archivo_de_referencia = "datos.csv";
PFont f;

PeasyCam c;
String[] sett;

PGraphics icong;
boolean piramide =false;
boolean rect = false;
boolean proyec= true;
boolean record = false;

void settings() {
  fullScreen(P3D, 2);
  PJOGL.setIcon("C3D.png");
  smooth();
}

void setup() {
  camaraInterfaz();
  instanciarDatos();
  instanciarFuente();
  pushStyle();
  colorMode(HSB);
  instanciarMapas();
  popStyle();
  setupGUI();
}

void draw() {
  noStroke();
  limpiarPantalla();

  //Grabar
  if (record) {
    String nombreOutput = datos.data[0][mapas[0].SELECTOR].replace("(", "").replace(")", "").replace("%", "");
    mapas[0].map.scale(-1, 1, 1);
    mapas[0].map.rotate(-90);
    beginRaw(DXF, nombreOutput+".dxf");
  }

  desactivarCamara();
  dibujarPrograma();

  //Dejar de grabar
  if (record) {
    endRaw();
    record = false;
    mapas[0].map.scale(-1, 1, 1);
    mapas[0].map.rotate(-90);
  }
}

void arreglarCam() {
  c.setViewport(0, 0, width, height);
  PGraphics3D pg = (PGraphics3D) this.g;
  PJOGL pgl = (PJOGL) pg.beginPGL();
  pg.endPGL();
  pgl.enable(PGL.SCISSOR_TEST);
  pgl.scissor (0, 0, width, height);
  pgl.viewport(0, 0, width, height);
  c.feed();
  perspective(60 * PI/180, width/(float)height, 1, 5000);
}

void mouseReleased() {
  if (mostrarTut) {
    mostrarTut = false;
    lista_datos.open();
  }
}

void camaraInterfaz() {
  c = new PeasyCam(this, 0);
  arreglarCam();
  c.setActive(false);
}

void instanciarDatos() {
  if (datos == null) {
    datos = new Datos(archivo_de_referencia);
  }
}

void instanciarFuente() {
  f = createFont("georgia.ttf", 48, true);
}

void instanciarMapas() {
  String ruta = "argentina_map_simple_expandido_V1.svg";
  for (int i = 0; i < cantMapas; i++) {
    if (mapas[i] == null) {
      mapas[i] = new Mapa(ruta, this, i * (separacion+width/2), 0, (width / cantMapas - (separacion * (i))), height);
      if (mapas[i] == mapas[1]) {
        mapas[1].cambiarDatos(ruta);
      }
    } else {
      mapas[i].setCam(i * (separacion+width/2), 0, (width / cantMapas - (separacion * (i))), height);
      //mapas[i].renovarDatos();
      mapas[i].cambiarDatos(ruta);

    }
  }
}

void limpiarPantalla() {
  setGLGraphicsViewport(0, 0, width, height);
  background(0);
}

void dibujarPrograma() {
  for (int i = 0; i < cantMapas; i++) {
    pushMatrix();
    mapas[i].dibujar();
    arreglarCam();
    dibujarInterfaz();
    popMatrix();
  }
}

void desactivarCamara() {
  if (cp5.isMouseOver()) {
    for (int i = 0; i < cantMapas; i++) {
      mapas[i].cam.setActive(false);
    }
  } else {
    for (int i = 0; i < cantMapas; i++) {
      mapas[i].cam.setActive(true);
    }
  }
}

void setGLGraphicsViewport(int x, int y, int w, int h) {
  PGraphics3D pg = (PGraphics3D) this.g;
  PJOGL pgl = (PJOGL) pg.beginPGL();
  pg.endPGL();
  pgl.enable(PGL.SCISSOR_TEST);
  pgl.scissor (x, y, w, h);
  pgl.viewport(x, y, w, h);
}