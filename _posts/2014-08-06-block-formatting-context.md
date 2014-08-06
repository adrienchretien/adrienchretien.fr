---
title: "Le block formatting context"
meta: "Un block formatting context permet de régler quelques petits problèmes liés à des enfants ou des éléments adjacents déclarés flottants."
date: 2014-08-06 21:04 +02:00
category: notes
tags: css technique
---

Un <i>block formatting context</i> (BFC) permet de régler quelques petits problèmes liés à des enfants ou des éléments adjacents déclarés flottants.

Le <i>[contexte de mise en forme de type bloc](http://www.w3.org/TR/CSS21/visuren.html#block-formatting)</i> spécifie que :

- les enfants d'un élément qui génère un BFC s'affichent les uns en dessous des autres à partir du haut;
- le contexte contient les éléments flottants;
- le contenu d'un BFC ne s'écoule pas autour d'un flottant adjacent;
- les marges verticales des enfants ne débordent pas du contexte.

Il est possible de créer ce type de contexte d'affichage en attribuant à un élément, l'une des déclarations suivantes :

- `float: left` ou `right`;
- `position: absolute` ou `fixed`;
- `display: inline-block`, `table`, `table-cell` ou `table-caption`;
- `overflow: hidden`, `scroll` ou `auto`.

La méthode la plus simple à utiliser est `overflow: hidden`, mais son contenu peut être amené à disparaître, par exemple : si un enfant déclaré avec une ombre portée n'a pas de marges externes déclarés ou que les marges internes de son parent ne le sont pas, il sera difficile de voir cette ombre. Du coup, et si c'est possible, il est peut-être préférable d'utiliser les déclarations `float: left` et `width: 100%` à la place.

<figure>
  <div style="overflow: hidden;">
    <p style="box-shadow: 0px 0px 1em 0 #333; padding: .25em; background-color: dodgerblue; color: white;">&lt;p&gt; déclaré avec un <code>box-shadow</code> dans un BFC généré avec <code>overflow: hidden</code>.</p>
  </div>
  <div style="float: left; width: 100%;">
    <p style="box-shadow: 0px 0px 1em 0 #333; padding: .25em; background-color: dodgerblue; color: white;">&lt;p&gt; déclaré avec un <code>box-shadow</code> dans un BFC généré avec <code>float: left</code> et <code>width: 100%</code>.</p>
  </div>
  <figcaption>Exemple de génération d'un <i>block formatting context</i>.</figcaption>
</figure>

Quelque part, le BFC est une sorte de lien entre l'élément qui le génère, les éléments adjacents et ses enfants dans le flux ou flottants. Il force le navigateur à récupérer des informations sur les dimensions et la flottaison d'un de ces derniers pour les prendre en compte dans ses calculs.

## Exemples d'utilisation

Un contexte de type bloc permet au parent qui le génère, de prendre en compte les dimensions de ses enfants même si ceux-ci sont flottants.

<figure>
  <div style="overflow: auto;">
    <div style="float: left; width: 48%;">
      <div style="padding: 1em; background-color: dodgerblue">
        <div style="float: left; width: 85%; padding: .25em; color: #555; background-color: gainsboro;">Enfant flottant dans un parent qui ne génère pas de BFC.</div>
      </div>
    </div>
    <div style="float: right; width: 48%;">
      <div style="overflow: hidden; padding: 1em; background-color: dodgerblue">
        <div style="float: left; width: 80%; padding: .25em; color: #555; background-color: gainsboro;">Enfant flottant dans un parent qui génère un BFC.</div>
      </div>
    </div>
  </div>
  <figcaption>Exemple de la contenance d'élément flottant.</figcaption>
</figure>

Un BFC empêche le contenu de s'adapter autour de l'élément flottant précédent.

<figure>
  <div style="overflow: hidden; padding: 1em; background-color: dodgerblue">
    <div style="float: left; width: 20%; padding: .25em; color: dimgray; background-color: gainsboro;">Enfant flottant.</div>
    <div style="float: right; width: 20%; padding: .25em; color: dimgray; background-color: gainsboro;">Enfant flottant.</div>
    <div style="overflow: hidden; padding: .25em; background-color: dimgray; color: white;">Enfant dont le contenu ne s'écoule pas autour des frères flottants car il est contenu dans un BFC.</div>
  </div>
  <figcaption>Exemple du non-écoulement du contenu autour des frères flottants.</figcaption>
</figure>

Aussi, un parent générant un <i>block formatting context</i> empêche la fusion des marges verticales avec les blocs adjacents.

<figure>
  <div style="color: white;">
    <div style="background-color: dodgerblue;"><p style="margin: 1em 0; padding: 0 .25em;">&lt;p&gt; avec des marges au-dessus et en-dessous, dans une &lt;div&gt; sans BFC.</p></div>
    <div style="background-color: dodgerblue;"><p style="margin: 1em 0; padding: 0 .25em;">&lt;p&gt; avec des marges au-dessus et en-dessous, dans une &lt;div&gt; sans BFC.</p></div>
    <div style="overflow: hidden; background-color: dodgerblue;"><p style="margin: 1em 0; padding: 0 .25em;">&lt;p&gt; avec des marges au-dessus et en-dessous, dans une &lt;div&gt; avec BFC.</p></div>
  </div>
  <figcaption>Exemple de la non-fusion des marges verticales avec les frères.</figcaption>
</figure>

Ainsi, lorsque l'on veut mettre en place une grille horizontale, il est utile de pouvoir contenir les divisions flottantes de chaque ligne.

<figure>
  <div style="overflow: hidden; padding: 1em; background-color: dodgerblue; text-align: center;">
    <div style="float: left; width: 32%; background-color: gainsboro;">1/3</div>
    <div style="float: left; width: 32%; margin-left: 2%; background-color: gainsboro;">1/3</div>
    <div style="float: left; width: 32%; margin-left: 2%; background-color: gainsboro;">1/3</div>
  </div>
  <div style="overflow: hidden; padding: 0 1em; background-color: dodgerblue; text-align: center;">
    <div style="float: left; width: 66.67%;"><p style="background: gainsboro;">2/3</p></div>
    <div style="box-sizing: border-box; float: left; width: 33.33%; padding-left: 1em"><p style="background: gainsboro;">1/3</p></div>
  </div>
  <figcaption>Exemples de grille avec divisions flottantes : la première a des gouttières fluides à 2% et la seconde a ses gouttières fixes à <code>1em</code>.</figcaption>
</figure>

## Pour plus de détails

- [CSS 101: Block Formatting Contexts](http://www.yuiblog.com/blog/2010/05/19/css-101-block-formatting-contexts/) : Article en anglais de Thierry Koblentz, à ma connaissance, l'un des premiers sur le sujet.
- [Ce que vous avez toujours voulu savoir sur CSS](http://iamvdo.me/blog/ce-que-vous-avez-toujours-voulu-savoir-sur-css#block-formatting-context) : Article de Vincent de Oliveira où il donne une explication très bien faite (et complète) avec en plus les inconvénients de chaque méthode.
- [Don't overthink it grids](http://css-tricks.com/dont-overthink-it-grids/) : Article en anglais de Chris Coyier pour faire des grilles simples.