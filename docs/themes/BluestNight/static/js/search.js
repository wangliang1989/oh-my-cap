"use strict";

var lunrIndex = undefined;
var rawIndex = [];
var sbox = document.getElementById("searchbox");
var sresults = document.getElementById("search-results");
var searchAnalytics = undefined;

function getJSON(url) {
  return new Promise(function(resolve, reject) {
    var req = new XMLHttpRequest();
    req.responseType = 'json';
    req.open('GET', url, true);
    req.addEventListener("load", function() {
      var status = req.status;
      if (status === 200)
        resolve(req.response);
      else
        reject(status);
    });
    console.log("Loading search index");
    req.send();
  });
}

function loadIndex(url) {
  return new Promise(function(resolve, reject) {
    getJSON(url).then(
      function(json) {
        rawIndex = json;
        lunrIndex = lunr(function () {
          this.ref('id');
          // These are all fields searched for results
          this.field('url');
          this.field('name');
          this.field('description');
          this.field('body');

          for (var i = 0; i < rawIndex.length; i++) {
            // Adding id allows to access other properties later
            rawIndex[i].id = i;
            this.add(rawIndex[i]);
          }
        });
        resolve(lunrIndex);
      },
      function(status) {
        console.error("Unable to load search index. Status: " + status);
        reject(status);
      }
    );
  });
}

function populateSearchbox() {
  // Trailing asterisk wildcards a potentially incomplete word
  var content = sbox.value;
  if (content.length > 0 && content[content.length - 1] !== " ")
    content += "*";
  // Empty previous results
  sresults.innerHTML = "";

  if (lunrIndex !== undefined) {
    var results = lunrIndex.search(content);

    // Add each result to a <a href="url"><div>Name</div></a>
    // and append to the results
    results.forEach(function(data) {
      var result = document.createElement("div");
      result.setAttribute("class", "search-result button");
      result.innerHTML = rawIndex[data.ref].name;
      var link = document.createElement("a");
      link.setAttribute("href", rawIndex[data.ref].url);
      // Add event handler to results to log search if using piwik
      if (_paq !== undefined) {
        link.addEventListener("click", function() {
          searchAnalytics = {
            keyword: sbox.value,
            numResults: results.length
          };
        });
      }
      link.appendChild(result);
      sresults.appendChild(link);
    });

    // Hide if no content (only asterisk, thanks to above line)
    sresults.setAttribute("class", results.length === 0 ? "hide" : "");
  }
}

sbox.addEventListener("keyup", populateSearchbox);
window.addEventListener("beforeunload", function(){
  if (_paq !== undefined && searchAnalytics !== undefined) {
    _paq.push(['trackSiteSearch',
        // Search keyword searched for
        searchAnalytics.keyword,
        // Search category selected in your search engine. If you do not need this, set to false
        false,
        // Number of results on the Search results page. Zero indicates a 'No Result Search Keyword'. Set to false if you don't know
        searchAnalytics.numResults
    ]);
  }
});
