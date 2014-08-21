---
title: "Le block formatting context"
meta: "Un block formatting context permet de régler quelques petits problèmes liés à des enfants ou des éléments adjacents déclarés flottants."
date: 2014-08-06 21:04 +02:00
category: notes
tags: css technique
---

Un <i lang="en">[block formatting context](http://www.w3.org/TR/CSS21/visuren.html#block-formatting)</i> (BFC) permet de régler quelques petits problèmes liés à des enfants ou des éléments adjacents déclarés flottants.


Ce type de contexte spécifie que&nbsp;:

<ul>
  <li>les enfants d’un élément qui génère un BFC s’affichent les uns en dessous des autres à partir du haut</li>
  <li>
    le contexte contient les éléments flottants
    <figure>
      <img src="/images/2014-08-06-contient-flottants.png" title="À droite, un bloc générant un BFC dont la hauteur tient compte de la hauteur du bloc flottant qu’il contient. À gauche, un bloc qui ne tient pas compte de cette hauteur." />
    </figure>
  </li>
  <li>
    le contenu d’un BFC ne s’écoule pas autour d’un flottant adjacent
    <figure>
      <img src="/images/2014-08-06-ecoulement-autour-flottants.png" title="Le BFC empêche l’écoulement du contenu (situé au centre) autour des flottants (situés sur les côtés)." />
    </figure>
  </li>
  <li>
    les marges verticales des enfants ne débordent pas du contexte
    <figure>
      <img src="/images/2014-08-06-fusion-marges.png" title="Le BFC contient les marges du paragraphe qu’il contient." />
    </figure>
  </li>
</ul>

Il est possible de créer un BFC en attribuant à un élément, l’une des déclarations suivantes&nbsp;:

- `float: left` ou `right`;
- `position: absolute` ou `fixed`;
- `display: inline-block`, `table`, `table-cell` ou `table-caption`;
- `overflow: hidden`, `scroll` ou `auto`.

La méthode la plus simple à utiliser est `overflow: hidden`, mais son contenu peut être amené à disparaître, par exemple&nbsp;: si un enfant est déclaré avec une ombre portée, il sera peut-être difficile de la voir.

<figure>
  <img src="/images/2014-08-06-debordements-caches.png" title="La méthode overflow cache l’ombre portée du paragraphe qu’il contient." />
</figure>

Quelque part, le BFC est une sorte de lien entre l’élément qui le génère, les éléments adjacents et ses enfants dans le flux ou flottants. Il force le navigateur à récupérer des informations sur les dimensions et la flottaison d’un de ces derniers pour les prendre en compte dans ses calculs.

## Pour plus de détails

- <span lang="en">[CSS 101&nbsp;: Block Formatting Contexts](http://www.yuiblog.com/blog/2010/05/19/css-101-block-formatting-contexts/)</span>&nbsp;: Article en anglais de Thierry Koblentz, à ma connaissance, l’un des premiers sur le sujet.
- [Ce que vous avez toujours voulu savoir sur CSS](http://iamvdo.me/blog/ce-que-vous-avez-toujours-voulu-savoir-sur-css#block-formatting-context)&nbsp;: Article de Vincent de Oliveira où il donne une explication très bien faite (et complète) avec en plus les inconvénients de chaque méthode.
