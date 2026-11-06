/////////////////////////////////////////////////////
//
// Démineur
// DM "UED 131 - Programmation impérative" 2023-2024
// NOM         : CARISTAN
// Prénom      : Ninon
// N° étudiant : 20232245
//
// Collaboration avec :  Ameylia CLEMENT, Elisabeth SALAME, Jeanne FREBAULT, Antoine 
//
/////////////////////////////////////////////////////

//
//Initialisation des variables globales utilisées
//
int etat, cote, lignes, colonnes, bandeau, etat_bloc, start, time, bomb_reste ; //Initialisation des variables pouvant être modifiées par la suite.
final int INIT = 0, STARTED = 1, OVER = 2,BLOC = 0, EMPTY = 1, FLAG = 2 ; //Initialisation des variables qui ne doivent pas pouvoir être modifiées.
PFont chrono, nbB ; //Initialisation des types de polices ajoutés.
int[][]paves = new int[30][16] ; //Initialisation du tableaux contenant l'états des blocs de la zone de blocs.
boolean[][]bombes = new boolean[30][16] ; //Initialisation du tableaux contenant les bombes placées de la zone de blocs.
int[][]nb_bombes = new int[3][3] ; //Initialisation du tableaux pour compter les bombes à côté aux dimensions permettant d'englober toute les case autour.

//
// Initialisation de la fenêtre graphique
//
void settings() 
{
  cote = 20 ;
  bandeau = 50 ;
  lignes = 16 ;
  colonnes = 30 ;
  size(colonnes*cote,lignes*cote+bandeau) ; //Initialisation de la taille de la fenêtre pour faire en sorte de pouvoir englober la zone de bloc et le bandeau.
  etat = INIT ; 
  etat_bloc = INIT ; 
}

//
// Initialisation du programme
//
void setup() 
{
  init();
}

//
// Initialisation du jeu
//
void init() 
{
  bomb_reste = 0 ; //Reinitialisation de la variable permettant de compte le nombre de bombes dans la zone de blocs.
  etat_bloc = BLOC ; 
  for(int i = 0; i<colonnes; i++)
  {
    for(int j = 0; j<lignes; j++)
    {
      paves[i][j] = etat_bloc ;
      bombes[i][j] = false ; //Reinitialisation des tableaux de bombes et d'états.
    }
  }
  while(bomb_reste<100) //Utilisation d'une boucle allant de 0 à 99 pour créer les 100 bombes de placement aléatoire dans la zone de blocs.
  {
    int posX_bomb = int(random(0,29)) ; //Choix aléatoire de la position de la bombe dans la dimension des colonnes.
    int posY_bomb = int(random(0,15)) ; //Choix aléatoire de la position de la bombe dans la dimension des lignes. 
    if(bombes[posX_bomb][posY_bomb] != true) //Condition pour ne pas mettre deux bombes au même endroit. 
    {
      bombes[posX_bomb][posY_bomb] = true ; //Affectation des positions de la bombes dans le tableau bombes. 
      bomb_reste++ ; //Comptage de la bombe dans le nombre de bombes présentes dans la zone de blocs.
    }
  }
  println(bomb_reste) ; 
  for(int i = 0; i<nb_bombes.length; i++)
  {
    for(int j = 0; j<nb_bombes.length ; j++)
    {
      nb_bombes[i][j] = 0 ; //Reinitialisation du tableaux contenant le nombre de bombes à côté de la case souhaitée.
    }
  } 
}

//
// boucle de rendu
// - met à jour le temps écoulé depuis le début de la résolution
// - appelle la fonction d'affichage
//
void draw() 
{
  display();
  if(start!=0) //Condition d'incrémentation de la variable time pour faire en sorte qu'elle ne varie pas à l'état init.
  if((time<999)&&(etat==1)) //Condition pour stopper l'incrémentation de la variable time quant elle atteint la valeur 999 ou quand l'on passe à l'état init ou over.
  time = (millis()-start)/1000 ; //Moyen d'incrémenter time à la bonne valeur soit en déduisant le temps écoulé avant le début de la partie (passage à état started) et en divisant par 1000 pour passer de millisecondes à seconde.
}

//
// calcule le nombre de bombes dans les 8 cases voisines
// (x, y) = coordonnées de la case
//
int voisins(int a, int b) 
{
  int nb_bomb = 0,nbX = 0, nbY ; //Instanciation des variables permettant de compte le nombre de bombes à côté et celles pour parcourir le tableau nb_bombes.
  for(int i = 0; i<nb_bombes.length; i++)
  {
    for(int j = 0; j<nb_bombes.length; j++)
    {
      nb_bombes[i][j] = 0 ; //Reinitialisation du tableau nb_bombes pour garder les "0" du début.
    }
  }
  if(((a>0)&&(b>0))&&((a<29)&&(b<15))) //Première condition excluant les blocs situés aux extrémités pour éviter de dépasser les limites de dimension du tableau bombes en parcourant toutes celles du tableau nb_bombes. 
  {
    for(int i = a-1; i<=(a+1); i++) //Boucle pour parcourir le tableau bombes sur la dimension des x.
    {
      nbY = 0 ; //Réinitialisation de la variable nbY pour rester dans une limite de dimension de 3 du tableau nb_bombes.
      for(int j = b-1; j<=(b+1); j++) //Boucle pour parcourir bombes sur la dimension des y.
      {
        if( bombes[i][j] == true) //Vérification de la présence d'une bombe dans la case étudiée.
        {
          nb_bomb++ ; //Incrémentation de la variable nb_bomb en conséquence.
          nb_bombes[nbX][nbY] = 2 ; //Signification de la présence de la bombes dans nb_bombes par le chiffre 2.
        }
        else nb_bombes[nbX][nbY] = 1 ; //Signification de l'absence de bombe par l'ajout du chiffre 1 dans nb_bombes. 
        nbY++ ; //Incrémentation de la vriable pour parcourir nb_bombes sur l'axe des y. 
      }
      nbX++ ; //Incrémentation de la variable pour parcourir nb_bombes sur l'axe des x. 
    }
  }
  if((a == 0)&&(b!=0)&&(b<15)) //Conditions dans le cas où on se trouve sur un carre du bord gauche pour ne pas parcourir les zones en dehors de la zone de blocs en excluant les coins.
  {
    nbX = 1 ; //On commence à 1 pour que dans nb_bombes, la première colonne garde ses valeurs initiales à 0 pour signifier l'absence de bloc.
    for(int i = a; i<=(a+1); i++) //Adaptation de la boucle pour ne pas prendre en compte la zone en dehors de celle des blocs.
    {
      nbY = 0 ; 
      for(int j = b-1; j<=(b+1); j++)
      {
        if( bombes[i][j] == true) 
        {
          nb_bomb++ ;
          nb_bombes[nbX][nbY] = 2 ; 
        }
        else nb_bombes[nbX][nbY] = 1 ; 
        nbY++ ;
      }
      nbX++ ; 
    }
  }
  if((a!=0)&&(b==0)&&(a<29)) //Condition pour similaire pour le bord du haut.
  {
    for(int i = a-1; i<=(a+1); i++)
    {
      nbY = 1 ; //Adaptation de la variable pour ajouter les bombes et absences de bombes au bon endroit. 
      for(int j = b; j<=(b+1); j++) //Adaptation de la boucle en conséquence.
      {
        if( bombes[i][j] == true) 
        {
          nb_bomb++ ;
          nb_bombes[nbX][nbY] = 2 ; 
        }
        else nb_bombes[nbX][nbY] = 1 ; 
        nbY++ ;
      }
      nbX++ ; 
    }
  }
  if((a==29)&&(b<15)&&(b>0)) //Condition similaire pour le bord droit, pas besoin ici de changer le début d'une quelconque variable car les 0 sont gardés à la fin.
  {
    for(int i = a-1; i<=a; i++)
    {
      nbY = 0 ; 
      for(int j = b-1; j<=(b+1); j++)
      {
        if( bombes[i][j] == true) 
        {
          nb_bomb++ ;
          nb_bombes[nbX][nbY] = 2 ; 
        }
        else nb_bombes[nbX][nbY] = 1 ; 
        nbY++ ;
      }
      nbX++ ; 
    }
  }
  if((a<29)&&(b==15)&&(a>0)) //Condition similaire pour le bord du bas, pas besoin non plus de changer le début des variables nb pour les mêmes raisons.
  {
    for(int i = a-1; i<=(a+1); i++)
    {
      nbY = 0 ; 
      for(int j = b-1; j<=b; j++)
      {
        if( bombes[i][j] == true) 
        {
          nb_bomb++ ;
          nb_bombes[nbX][nbY] = 2 ; 
        }
        else nb_bombes[nbX][nbY] = 1 ; 
        nbY++ ;
      }
      nbX++ ; 
    }
  }
  if((a==0)&&(b==0)) //Condition pour le coin supérieur gauche.
  {
    nbX = 1 ; //Adaptation de la variable en conséquence.
    for(int i = a; i<=(a+1); i++)
    {
      nbY = 1 ; //Adaptation de la variable en conséquence.
      for(int j = b; j<=(b+1); j++)
      {
        if( bombes[i][j] == true) 
        {
          nb_bomb++ ;
          nb_bombes[nbX][nbY] = 2 ; 
        }
        else nb_bombes[nbX][nbY] = 1 ; 
        nbY++ ;
      }
      nbX++ ; 
    }
  }
  if((a==29)&&(b==15)) //Condition pour le coin inférieur droit, pas besoin de modifier le début des variables nb. 
  {
    for(int i = a-1; i<=a; i++)
    {
      nbY = 0 ; 
      for(int j = b-1; j<=b; j++)
      {
        if( bombes[i][j] == true)
        {
          nb_bomb++ ;
          nb_bombes[nbX][nbY] = 2 ; 
        }
        else nb_bombes[nbX][nbY] = 1 ; 
        nbY++ ;
      }
      nbX++ ; 
    }
  }
  if((a==0)&&(b==15)) //Condition pour le coin inférieur gauche.
  {
    nbX = 1 ; //Adaptation de la variable pour bien placer les absences et présences de bombe. 
    for(int i = a; i<=(a+1); i++)
    {
      nbY = 0 ; 
      for(int j = b-1; j<=b; j++)
      {
        if( bombes[i][j] == true)
        {
          nb_bomb++ ;
          nb_bombes[nbX][nbY] = 2 ; 
        }
        else nb_bombes[nbX][nbY] = 1 ; 
        nbY++ ;
      }
      nbX++ ; 
    }
  }
  if((a==29)&&(b==0)) //Condition pour le coin supérieur droit.
  {
    for(int i = a-1; i<=a; i++)
    {
      nbY = 1 ; //Adaptation de la vriable en conséquence. 
      for(int j = b; j<=(b+1); j++)
      {
        if( bombes[i][j] == true)
        {
          nb_bomb++ ;
          nb_bombes[nbX][nbY] = 2 ; 
        }
        else nb_bombes[nbX][nbY] = 1 ; 
        nbY++ ;
      }
      nbX++ ; 
    }
  }
  return nb_bomb ; //Retour de la variable correspondant au nombre de bombes présentes à côté de la case concernée. 
}

//
// affiche un bloc
// (x, y) = coordonnées du bloc
// (w, h) = dimensions du bloc
//
void drawBloc(int x, int y, int w, int h) 
{
  pushMatrix() ; //Sauvegarde de l'emplacement normal des éléments pour éviter de modifier tout le contenu. 
  translate(1,bandeau) ; //Pour déplacer les blocs en dessous du bandeau. 
  pushStyle() ; //Sauvegarde du style par défaut (couleurs des éléments ici) pour ne pas modifier tout le contenu. 
  stroke(255) ;
  fill(255) ;
  rect(x*cote,y*cote,w-1,h-1) ; //Carré blanc de fond pour faire les lignes lumineuses sur les blocs. 
  stroke(175) ;
  fill (175) ;
  rect(x*cote+2,y*cote+2,w-4,h-4) ; //Carré gris clair par au dessus.
  stroke(128) ;
  fill (128) ;
  line (x*cote+1,y*cote+h-2,x*cote+w-1,y*cote+h-2) ;
  line (0+x*cote,y*cote+h-1,x*cote+w-1,y*cote+h-1) ;
  line (x*cote+w-2,y*cote+1,x*cote+w-2,y*cote+h-1) ;
  line (x*cote+w-1,0+y*cote,x*cote+w-1,y*cote+h-1) ; //Lignes foncées pour faire l'ombre sur les blocs.
  popMatrix() ; //Remise en place de la sauvegarde pour annuler ici le translate.
  popStyle() ; //Remise en place de la sauvegarde pour annuler ici tous les changements de couleur. 
}

//
// affiche un drapeau dans la case
// (x, y) = coordonnées de la case
//
void drawFlag(int x, int y) 
{
  pushMatrix() ;
  translate(1,bandeau) ;
  pushStyle() ;
  fill(0) ;
  stroke(0) ;
  line(x*cote+10,y*cote+4,x*cote+10,y*cote+12) ; //Dessin du manche du drapeau.
  rect(x*cote+6,y*cote+13,9,2) ;
  rect(x*cote+4,y*cote+15,13,2) ; //Dessin du support du drapeau. 
  fill(255,0,0) ;
  stroke(255,0,0) ;
  triangle(x*cote+5,y*cote+6,x*cote+9,y*cote+4,x*cote+9,y*cote+8) ; //Dessin de la partie flottante du drapeau. 
  popMatrix() ;
  popStyle() ;
}

//
// affiche une bombe dans la case
// (x, y) = coordonnées de la case
//
void drawBomb(int x, int y) 
{
  pushMatrix() ;
  translate(1,bandeau) ;
  pushStyle() ;
  fill(0) ;
  ellipse(10+x*cote,10+y*cote,9,9) ; //Dessin du rond central de la bombe. 
  line(5+x*cote,5+y*cote,15+x*cote,15+y*cote) ;
  line(5+x*cote,15+y*cote,15+x*cote,5+y*cote) ;
  line(10+x*cote,4+y*cote,10+x*cote,16+y*cote) ;
  line(4+x*cote,10+y*cote,16+x*cote,10+y*cote) ; //Dessins des piques sur les côtés de la bombe. 
  fill(255) ;
  ellipse(8.5+x*cote,9.5+y*cote,4,4) ; //Dessin du point de lumière sur la bombe. 
  popMatrix() ;
  popStyle() ;
}

//
// affiche dans la case le nombre de mines
//  présentes dans les 8 cases voisines 
//
void drawNbBombesACote(int x, int y) 
{
  nbB = createFont("mine-sweeper",10) ; //Création de la police mine-sweeper pour les nombres de bombes à côté. 
  int v ; //Création d'une variable pour sauvegarder la valeur de la fonction voisin. 
  textFont(nbB) ; //Application de la police. 
  v = voisins(x,y) ; //Affectation de la valeur de retour de la fonction voisins à la variable. 
  pushStyle() ; 
  switch(v)
  {
    case 1 : fill(0,35,245) ; 
             break ; 
    case 2 : fill(55,125,35) ; 
             break ; 
    case 3 : fill(235,50,35) ; 
             break ; 
    case 4 : fill(120,25,120) ; 
             break ; 
    case 5 : fill(115,20,10) ; 
             break ; 
    case 6 : fill(55,125,125) ; 
             break ; 
    default : fill(0) ; //Changements de la couleur de la police en fonction du chiffre. 
  }
  if(v != 0) //Condition pour ne pas afficher les "0". 
  text(v,x*cote+5,y*cote+bandeau+15) ; //Dessin du texte à la bonne position sur la grille de la zone de blocs. 
  popStyle() ;
}

//
// affiche le nombre de mines restant à localiser
//
void drawScore() 
{
  pushStyle() ; 
  String b_r ; //Création d'une variable pour sauvegarder et modifier l'affichage du texte. 
  if(bomb_reste<100) //Condition pour afficher les 0 voulus devant le nombre quand il est inférieur à 100.
  {
    if(bomb_reste<10) //Condition pour afficher les 0 voulus devant le nombre quand il est inférieur à 10.
    b_r = "00"+bomb_reste ; //Mise en place des deux 0 si la condition est vérifiée. 
    else b_r = "0"+bomb_reste ; //Mise en place du 0 si la condition "<100" est vérifiée mais pas celle "<10". 
  }
  else b_r = ""+bomb_reste ; //Ne pas afficher de zéro si le nombres est supérieur à 100. 
  fill(0) ; 
  rect(5,5,80,40) ; //Dessin du rectangle de fond pour recueillir de compte du score. 
  fill(90,10,10) ; 
  text("888",5,40) ; //Dessin du fond foncé pour afficher le score.
  fill(255,0,0) ; 
  text(b_r,5,40) ; //Dessin du score dans un rouge plus clair. 
  popStyle() ;
}

//
// affiche le temps écoulé depuis le début de la résolution
//
void drawTime() 
{
  chrono = createFont("DSEG7 Classic-Bold", 32) ; //Création de la police DSEG7 classic-bold. 
  textFont(chrono) ; //Application de la police. 
  pushStyle() ; 
  String t ; 
  if(time<100)
  {
    if(time<10) t = "00"+time ; 
    else t = "0"+time ; 
  }
  else t = ""+time ; 
  fill(0) ; 
  rect(width-85,5,80,40) ; 
  fill(90,10,10) ; 
  text("888",width-85,40) ; 
  fill(255,0,0) ; 
  text(t,width-85,40) ; 
  popStyle() ; 
}

//
// dessine un smiley content au centre du bandeau
//
void drawHappyFace() 
{
  pushMatrix() ;
  translate(width/2,25) ; //Décalage pour afficher le bloc du smiley et le smiley à l'endroit voulu du bandeau. 
  pushStyle() ;
  stroke(255) ;
  fill(255) ;
  rect(-20,-20,39,39) ;
  stroke(175) ;
  fill (175) ;
  rect(-18,-18,36,36) ;
  stroke(128) ;
  fill (128) ;
  line (-19,18,19,18) ;
  line (-20,19,19,19) ;
  line (18,-19,18,19) ;
  line (19,-20,19,18) ; //Dessin du bloc de fond.
  strokeWeight(2) ;
  stroke(0) ;
  fill(255,255,0) ;
  ellipse(0,0,30,30) ; //Dessin de la tête.
  fill(0) ;
  ellipse(-6,-4,2.5,2.5) ;
  ellipse(6,-4,2.5,2.5) ; //Dessin des yeux.
  noFill() ;
  arc(0,0,17,17,QUARTER_PI, HALF_PI+QUARTER_PI) ; //Dessin de la bouche.
  popMatrix() ;
  popStyle() ;
}

//
// dessine un smiley mécontent au centre du bandeau
//
void drawSadFace() 
{
  pushMatrix() ;
  translate(width/2,25) ;
  pushStyle() ;
  stroke(255) ;
  fill(255) ;
  rect(-20,-20,39,39) ;
  stroke(175) ;
  fill (175) ;
  rect(-18,-18,36,36) ;
  stroke(128) ;
  fill (128) ;
  line (-19,18,19,18) ;
  line (-20,19,19,19) ;
  line (18,-19,18,19) ;
  line (19,-20,19,18) ;
  strokeWeight(2) ;
  stroke(0) ;
  fill(255,255,0) ;
  ellipse(0,0,30,30) ;
  fill(0) ;
  line(-9,-6,-3,0) ;
  line(-3,-6,-9,0) ;
  line(3,-6,9,0) ;
  line(9,-6,3,0) ;
  noFill();
  arc(0,15,17,17,PI+QUARTER_PI, PI+HALF_PI+QUARTER_PI) ;
  popMatrix() ;
  popStyle() ;
}

//
// affiche le démineur
//
void display() 
{
  background(64) ; //Mise en place de la couleur de fond de la zone de bloc. 
  pushStyle() ;
  stroke(192) ;
  fill(192) ;
  rect(0,0,width,bandeau) ; //Mise en place de la couleur de fond du bandeau. 
  popStyle() ;
  if ((etat == INIT)||(etat == STARTED)) drawHappyFace() ; //Afficher le smiley content dans le cas où on a pas perdu. 
  else drawSadFace() ; //Dessin du smiley mort si on a perdu. 
  for(int i = 0; i<colonnes; i++) //Boucle pour parcourir les colonnes de la zone de blocs. 
    {
      for(int j = 0; j<lignes; j++) //Boucle pour parcourir les lignes de la zone de blocs. 
      {
        if((paves[i][j] == BLOC)||(paves[i][j] == FLAG)) // Vérification que l'on est pas dans l'état EMPTY pour afficher les blocs.
        {
          drawBloc(i,j,cote,cote) ; //Dessin du bloc à la position dans les colonnes i et dans les lignes j. 
          if(paves[i][j] == FLAG) drawFlag(i,j); //Dessin à la même position si on est à l'état FLAG du drapeau. 
        }
        if((bombes[i][j]!=true)&&(paves[i][j] == EMPTY)) //Condition pour gérer les nombres de bombes à côté quand on a découvert un bloc. 
        {
          drawNbBombesACote(i,j) ; //Affiche le nombre de bombes à côté sur la case découverte. 
          decouvre(i,j) ; //Vérifie s'il y a des bombes à côté et s'il n'y en a pas, découvre les cases vides ainsi que le nombre qu'elles comportent. 
          decouvre2(i,j) ; //Vérifie si les drapeaux sont bien placés ou non et s'il n'y sont pas, passe l'état à OVER et sinon découvre les cases dépourvues de bombes. 
        }
        if((bombes[i][j]==true)&&(etat==2))displayBombs(i,j) ; //Dans le cas où on a perdu, affiche l'emplacement de toutes les bombes. 
      }
  }
  drawTime() ; //Met à jour l'affichage du temps écoulé depuis le début du commencement de la partie. 
  drawScore() ; //Met à jour l'affichage du score. 
}

//
// affiche le démineur quand on a perdu
// = on révèle l'emplacement des bombes
// et on affiche le smiley mécontent
//
void displayBombs(int x, int y) 
{
  paves[x][y] = EMPTY ; //Découvre les cases contenant les bombes. 
  int posX = x*cote ; 
  int posY = y*cote+bandeau ; 
  pushMatrix() ; 
  pushStyle() ;
  stroke(255,50,50) ; 
  fill(255,50,50) ; 
  rect(posX,posY,cote,cote) ; //Création d'un fond rouge aux position des bombes. 
  popStyle() ; 
  popMatrix() ; 
  drawBomb(x,y) ; //Affiche la bombe à l'emplacement voulu. 
}

//
// calcule les blocs qui doivent être découverts
// = les blocs vides autour si (x, y) est vide
//
void decouvre(int x, int y) 
{
  int b = voisins(x,y), x1 = x-1, y1; //Sauvegarde de la valeur issue de voisin dans une variable et création de deux variables pour parcourir paves. 
  if(b == 0) //Condition pour découvrir qu'il n'y ait pas de bombes autour de la case découverte. 
  {
    for(int i = 0; i<3; i++) //Boucle parcourant la dimension x de nb_bombes. 
    {
      y1 = y-1 ; //Initialisation de la variable y1 pour parcourir paves. 
      for(int j = 0; j<3; j++) //Boucle pour parcourir la dimension y de nb_bombes. 
      {
        if(nb_bombes[i][j] == 1) paves[x1][y1] = EMPTY ; //Dans le cas où la condition de l'absence de bopmbes dans le bloc concerné est vérifié, le bloc est découvert. 
        y1++ ; 
      }
      x1++ ;
    } 
  }
}

//
// calcule les blocs qui doivent être découverts
// = les blocs vides autour de la case (x, y) portant un numéro, 
// dont on a localisé tous les blocs voisins
//
void decouvre2(int x, int y) 
{
  int bom = voisins(x,y), x1 = x-1, y1, boom = 0; //Création d'une variable pour sauvegarder la valeur de la fonction voisins ainsi que celle des positions de x et y dans le tableau paves et bombes en plus d'une pour vérifier le nombre de bombes comptée par drapeau bien placé. 
  for(int i = 0; i<3; i++) //Boucle parcourant la dimension x de nb_bombes. 
  {
    y1 = y-1 ; //Initialisation de la variable y1 de la position dans paves et bombes.
    for(int j = 0; j<3; j++) //Boucle parcourant la dimension y de nb_bombes. 
    {
      if(nb_bombes[i][j] != 0) //Condition vérifiant que l'on se situe bien dans la zone de blocs. 
      {
        if((paves[x1][y1] == FLAG)&&(bombes[x1][y1] == false)) etat = OVER ; //Si le drapeau est mal placé alors on passe dans l'état OVER. 
        if((paves[x1][y1] == FLAG)&&(bombes[x1][y1] == true)) boom++ ; //Si le drapeau est bien placé on incrémente la variable pour compter le nombre de drapeaux bien placés. 
      }
      y1++ ; 
    }
    x1++ ; 
  }
  x1 = x-1 ; //Réinitialisation de la variable x1 cette fois pour le tableau paves uniquement. 
  if(bom == boom) //Vérifier que l'on a bien un nombre de drapeaux bien placés égal au nombre de bombes à côté. 
  {
    for(int i = 0; i<3 ; i++)
    {
      y1 = y-1 ; 
      for(int j = 0; j<3; j++)
      {
        if(nb_bombes[i][j] == 1) paves[x1][y1] = EMPTY ; //Découvre les cases adjacentes s'il n'y a pas de bombes. 
        y1++ ; 
      }
      x1++ ; 
    }
  }
}

//
// met à jour le nombre de drapeaux voisins 
// qui ont été localisés et marqués
//
void updateNbDrapeaux(int x, int y) 
{
  if(paves[x][y] == FLAG) bomb_reste-- ; //Décrémente le score si un drapeau est placé dans la zone de blocs. 
  else if(paves[x][y] == BLOC) bomb_reste++ ; //Incrémente le score si un drapeau est retiré de la zone de blocs. 
}

//
// gère les interactions souris
//
void mouseClicked() 
{
  boolean passStarted, passInit ; //Création de deux variables pour vérifier la zone du clic. 
  int clicX, clicY ; //Création de deux variables pour prendre la position du clic dans la zone de blocs. 
  passStarted = mouseY > bandeau ; //Condition du départ du jeu si le clic a lieu dans la zone des blocs. 
  passInit = ((mouseX>(width/2-20))&&(mouseX<(width/2+20)))&&((mouseY>5)&&(mouseY<45)) ; //Condition du passage à l'état INIT si un clic a lieu sur le bloc du smiley. 
  if((etat == STARTED)&&(passStarted == true)) //Condition pour vérifier que le jeu est bien commencé pour ne pas découvrir une bombes ou un bloc en voulant commencer à jouer. 
  {
    clicY = (mouseY-bandeau)/cote ; //Affectation de la position sur l'axe des y du clic dans la zone de blocs.
    clicX = mouseX/cote ; //Affectation de la position sur l'axe des x du clic dans la zone de blocs. 
    switch(mouseButton) //Simplification du code par l'utilisation d'un switch pour déterminer si on a affaire à un clic gauche ou droit. 
    {
      case LEFT : if((paves[clicX][clicY] == BLOC)) //Dans le cas d'un clic gauche, vérifier que l'état du bloc est à BLOC. 
                  {
                    paves[clicX][clicY] = EMPTY ; //Si la condition est vérifiée, passer l'état du bloc à EMPTY. 
                    if(bombes[clicX][clicY] == true) etat = OVER ; //Si la case découverte contenait une bombe et que la condition est vérifiée, alors passer état à OVER. 
                  }
                  break ; //Dissocier les case dans leurs instructions entre eux. 
      case RIGHT : if((paves[clicX][clicY] == BLOC)) //Dans le cas d'un clic droit, vérifier si l'état du bloc est à BLOC. 
                   { 
                     paves[clicX][clicY] = FLAG ; //Si la condition est vérifiée, passer l'état du bloc à FLAG.
                     updateNbDrapeaux(clicX,clicY) ; //décrémenter en conséquence le score. 
                   }
                   else if((paves[clicX][clicY] == FLAG)) //Dans le cas d'un clic droit, vérifier si l'état du bloc est à FLAG. 
                   {
                     paves[clicX][clicY] = BLOC ; //Si la condition est vérifiée, passer l'état du bloc à BLOC. 
                     updateNbDrapeaux(clicX,clicY) ; //Décrémenter en conséquence le score. 
                   }
                   break ; 
      default : break ; //Mise en place d'un défault pout éviter un quelconque soucis de compilation. 
    }
  }
  switch(etat) //Simplification du code en utilisant un switch pour vérifier l'état de la variable etat. 
  {
    case 0 : if(passStarted == true) //Dans le cas où elle vaut 0 (à INIT), vérifier si la condition de départ du jeu est vérifiée. 
             {
               etat = STARTED; //Passage de l'état du jeu à STARTED. 
               start = millis() ; //Prendre la valeur du départ du chronomètre. 
             }
             break ; 
    case 1 : if(passInit == true) //Dans le cas où elle vaut 1 (soit STARTED), vérifier si la condition de nouvelle partie est vérifiée. 
             {
               etat = INIT ; //Passage de l'état du jeu à INIT. 
               init() ; //Appeler la fonction init pour remettre à jour tous les tableaux et variables. 
             }
    case 2 : if(passInit == true) //Dans le cas où elle vaut 2 (soit OVER), vérifier si la condition de nouvelle partie est vérifiée.
             {
               etat = INIT ; 
               init() ; 
             }
             break ; 
    default : break ; 
  }
}
