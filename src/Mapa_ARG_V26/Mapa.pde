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

class Mapa {

  int posCamX, posCamY, dimensionCamX, dimensionCamY;
  int selectMaximo = 0;
  int selectMinimo = 0;
  int SELECTOR = 0;
  color[] colores;
  PShape mapa_svg, map;
  PeasyCam cam;
  CameraState estado;
  PApplet p;

  Mapa (String ruta, PApplet p, int pCamX, int pCamY, int dCamX, int dCamY) {
    mapa_svg  = loadShape(ruta);
    map = createShape(GROUP);
    cam = new PeasyCam(p, 900);
    this.p = p;
    setCam(pCamX, pCamY, dCamX, dCamY);
    colores = new color[24];
    addChilds();
  }

  void renovarDatos() {
    datos.renovarDatos(SELECTOR);
  }

  void rotar() {
    if (auto_rotar) {
      cam.rotateX(sin(frameCount/100.0)/4000.0);
      cam.rotateY(cos(frameCount/100.0)/4000.0);
    }
  }

  void mostrarTexto() {
    textAlign(CENTER);
    fill(0);
    pushStyle();
    textSize(16);
    if (SELECTOR == 0) {
      text("República Argentina", posCamX+dimensionCamX/2, 60);
    } else {
      text(datos.data[0][SELECTOR], posCamX+dimensionCamX/2, 60);
      mostrarMaxMin();
    }
    popStyle();
  }

  void mostrarMaxMin() {
    int valMax = 0, valMin = 0;
    float[] vals = new float[datos.poblacion.length];
    for (int i = 0; i < datos.poblacion.length; i++) {
      String s =datos.data[i+1][SELECTOR].replace(",", ".");
      vals[i] = float(s);
    }
    //printArray(vals);
    float max = max(vals);
    float min = min(vals);
    pushStyle();
    textSize(14);

    for (int i = 0; i < datos.poblacion.length; i++) {
      if (vals[i] == max) {
        valMax = i;
      } else if (vals[i] == min) {
        valMin = i;
      }
    }
    if (valMax + 1 == 23) {
      text("Maximo "+ "Tierra del Fuego, Antártida.." + ": "+ max, posCamX+dimensionCamX * 0.25, height*0.9);
      text("Minimo "+datos.data[valMin+1][0]+": "+ min, posCamX+dimensionCamX * 0.75, height*0.9);
    }
    else if (valMin + 1 == 23) {
      text("Maximo "+datos.data[valMax+1][0]+": "+ max, posCamX+dimensionCamX * 0.25, height*0.9);
      text("Minimo "+ "Tierra del Fuego, Antártida.." + ": "+ min, posCamX+dimensionCamX * 0.75, height*0.9);
    }
    else {
      text("Maximo "+datos.data[valMax+1][0]+": "+ max, posCamX+dimensionCamX * 0.25, height*0.9);
      text("Minimo "+datos.data[valMin+1][0]+": "+ min, posCamX+dimensionCamX * 0.75, height*0.9);
    }
    popStyle();
  }

  void setCam(int pCamX, int pCamY, int dCamX, int dCamY) {
    posCamX = pCamX;
    posCamY = pCamY;
    dimensionCamX = dCamX;
    dimensionCamY = dCamY;
    cam.setMinimumDistance(500);
    cam.setMaximumDistance(1250);
    cam.setViewport(posCamX, posCamY, dimensionCamX, dimensionCamY);
  }

  void setGLGraphicsViewport(int x, int y, int w, int h) {
    PGraphics3D pg = (PGraphics3D) p.g;
    PJOGL pgl = (PJOGL) pg.beginPGL();
    pg.endPGL();
    pgl.enable(PGL.SCISSOR_TEST);
    pgl.scissor (x, y, w, h);
    pgl.viewport(x, y, w, h);
  }

  void grabarEstadoCam() {
    estado = cam.getState();
  }

  void volverEstadoCam() {
    cam.setState(estado, 1000);
  }

  void dibujar() {
    int y_inv =  height - posCamY - dimensionCamY;
    setGLGraphicsViewport(posCamX, y_inv, dimensionCamX, dimensionCamY);
    cam.feed();
    rotar();
    perspective(60 * PI/180, dimensionCamX/(float)dimensionCamY, 1, 5000);
    //background(#FCFAFA);
    background(#D8D8D8);
    translate(-150, -350, 0);
    lights();
    shape(map, 0, 0);
  }

  void cambiarDatos(String ruta) {
    renovarDatos();
    mapa_svg  = loadShape(ruta);
    map = createShape(GROUP);
    datos.setMaximo(selectMaximo);
    datos.setMinimo(selectMinimo);
    addChilds();
  }

  void  addChilds() {
     for (int i = 0; i < mapa_svg.getChildCount(); ++i) {
    PShape state = mapa_svg.getChild(i);

    if (i==1) {
      //Agregar base
      PShape arg = state.getChild("ARGENTINA");
      PShape base = connectShapesBase(arg, 10);
      if (SELECTOR!=0)map.addChild(base);

      for (int j = 0; j < datos.provincias.length; j++) {

        PShape provincia = state.getChild(datos.provincias[j]);

        //stroke(0, 20);

        float altura = map(datos.poblacion[j],datos.minPoblacion, datos.maxPoblacion, 10, 500);

          colores[j] = color(56+(altura/500*200), 255, 255);
          fill(colores[j]);

          PShape group = createShape(GROUP);

          PShape connect = connectShapes(provincia, altura);
          group.addChild(provincia);
          group.addChild(connect);

          map.addChild(group);
        }
      }
    }
  }

  PShape connectShapes(PShape normal, float offset) {
    float x=0, y=0;

    for (int i = 0; i < normal.getVertexCount(); i++) {
      PVector n = normal.getVertex(i);
      x+=n.x;
      y+=n.y;
    }
    x/=normal.getVertexCount();
    y/=normal.getVertexCount();
    // stroke(0, 20);
    //cantidad de puntos que saltea +1  ;  Ej; 1 = no saltea ningun punto
    int saltear = 1;
    PShape s = createShape();
    if (proyec) {
      s.beginShape(TRIANGLE_STRIP);
      for (int i = 0; i < normal.getVertexCount()+1; i = i + saltear) {
        PVector n = normal.getVertex(i%normal.getVertexCount());
        s.vertex(n.x, n.y, 0);
        s.vertex((n.x+x+x)/3, (n.y+y+y)/3, offset);
      }
      //  noStroke();
      for (int i = 0; i < normal.getVertexCount()+1; i= i + saltear) {
        PVector n = normal.getVertex(i%normal.getVertexCount());
        s.vertex(x, y, offset);
        s.vertex((n.x+x+x)/3, (n.y+y+y)/3, offset);
      }
      s.endShape(CLOSE);
    } else if (piramide) {
      s.beginShape(TRIANGLE_STRIP);
      for (int i = 0; i < normal.getVertexCount()+1; i= i + saltear) {
        PVector n = normal.getVertex(i%normal.getVertexCount());
        s.vertex(n.x, n.y, 0);
        s.vertex(x, y, offset);
      }
      s.endShape(CLOSE);
    } else if (rect) {
      s.beginShape(TRIANGLE_STRIP);
      for (int i = 0; i < normal.getVertexCount()+1; i= i + saltear) {
        PVector n = normal.getVertex(i%normal.getVertexCount());
        s.vertex(n.x, n.y, 0);
        s.vertex(n.x, n.y, offset);
      }
      // noStroke();
      for (int i = 0; i < normal.getVertexCount()+1; i= i + saltear) {
        PVector n = normal.getVertex(i%normal.getVertexCount());
        s.vertex(x, y, offset);
        s.vertex(n.x, n.y, offset);
      }
      s.endShape(CLOSE);
    }
    noStroke();
    return s;
  }

  PShape connectShapesBase(PShape normal, float offset) {
    float x=0, y=0;

    for (int i = 0; i < normal.getVertexCount(); i++) {
      PVector n = normal.getVertex(i);
      x+=n.x;
      y+=n.y;
    }
    x/=normal.getVertexCount();
    y/=normal.getVertexCount();
    // stroke(220, 20);
    //cantidad de puntos que saltea +1  ;  Ej; 1 = no saltea ningun punto
    int saltear = 1;
    PShape s = createShape();

    int corrimiento = 9;

    s.beginShape(TRIANGLE_STRIP);
    s.fill(255);
    for (int i = 0; i < normal.getVertexCount()+1; i= i + saltear) {
      PVector n = normal.getVertex(i%normal.getVertexCount());
      s.vertex(n.x, n.y, -corrimiento);
      s.vertex(n.x, n.y, offset-corrimiento);
    }

    for (int i = 0; i < normal.getVertexCount()+1; i= i + saltear) {
      PVector n = normal.getVertex(i%normal.getVertexCount());
      s.vertex(x, y, offset-corrimiento);
      s.vertex(n.x, n.y, offset-corrimiento);
    }

    for (int i = 0; i < normal.getVertexCount()+1; i= i + saltear) {
      PVector n = normal.getVertex(i%normal.getVertexCount());
      s.vertex(x, y, -corrimiento);
      s.vertex(n.x, n.y, -corrimiento);
    }
    s.endShape(CLOSE);
    return s;
  }
}