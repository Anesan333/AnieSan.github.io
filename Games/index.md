---
layout: page
title: "游戏策划文章"
---

<h1>{{ page.title }}</h1>

<ul>
{% for post in site.Games %}
  {% unless post.url == page.url %}
    <li><a href="{{ post.url | relative_url }}">{{ post.title }}</a></li>
  {% endunless %}
{% endfor %}
</ul>
