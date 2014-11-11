/** Libraries and other files to import */

/** 
 * LastfmAPI & NowPlaying from David Singleton's project now-playing-radiator
 * Url: https://github.com/dsingleton/now-playing-radiator
 */
LastfmAPI = function(api_key) {
    this.api_key = api_key;
};
LastfmAPI.prototype = {
    root: 'http://ws.audioscrobbler.com/2.0/',
    
    get: function (method, params, success, error)
    {
        jQuery.ajax({
            url: this.root,
            dataType: "jsonp",
            data: jQuery.extend({
                'api_key': this.api_key,
                'format': 'json',
                'method': method
            }, params),
            // Forces JSONP errors to fire, needs re-evaluation if long polling is used
            timeout: 2000
        })
        .success(function(response) { 
            (response.error ? error : success)(response);
        })
        .error(function() {
            // JSONP limitations mean we'll only get timeout errors
            console.log({error: 0, method: method, message: 'HTTP Error'});
        });
    },
    
    getNowPlayingTrack: function(user, success, error)
    {
        this.get('user.recenttracks', {user: user}, function(response) {
            var track = response.recenttracks.track[0];
            
            if (track && track['@attr'] && track['@attr'].nowplaying) {
                success(track);
            }
            else {
                success(false);
            }
        }, error);
    },
  
    getAlbumInfo: function(mbid, success, error)
    {
        this.get('album.getInfo', {mbid: mbid}, function(response) {
            var album = response.album;
            if (album) {
                success(album);
            }
            else {
                success(false);
            }
        }, error);
    }
};

NowPlaying = function(api, user, callback, interval) {
    this.api = api;
    this.user = user;
    this.callback = callback;
    
    /* AutoUpdate frequency - Last.fm API rate limits at 1/sec */
    this.interval = interval || 5;
};
NowPlaying.prototype = {
    
    update: function()
    {
        this.api.getNowPlayingTrack(
            this.user,
            jQuery.proxy(this.handleNowPlayingTrackResponse, this), 
            function(error) { console && console.log(error); }
        );
    },
  
    updateAlbum: function (mbid, track)
    {
        this.api.getAlbumInfo(
            mbid,
            jQuery.proxy(this.handleAlbumInfoResponse, this, track),
            function(error) { console && console.log(error); }
        );
    },
    
    autoUpdate: function()
    {
        // Do an immediate update, don't wait an interval period
        this.update();
        
        // Try and avoid repainting the screen when the track hasn't changed
        setInterval(jQuery.proxy(this.update, this), this.interval * 1000);
    },
    
    handleNowPlayingTrackResponse: function(response)
    {
        if (response) {
            var track = {
                name: response.name,
                artist: response.artist['#text'],
                album: response.album['#test']
            };
                
            this.updateAlbum(response.album.mbid, track);
        }
    },
  
    handleAlbumInfoResponse: function(track, response) {
        if (response) {
            track.cover = response.image;
          
            this.callback(track);
        }
        else {
            this.callback(null);
        }
    }
      
};

/** Personnal script */

(function (document) {
  function displayTrack(track) {
    // TODO: Execute only if track is not null.
    // TODO: Better css style.
    // TODO: Reduce browser reflow or repaints by verifying the .js-lastfm content.
    function setContext() {
      var $footer = $('.p-footer'),
          $aside = $('<aside><p><small class="js-lastfm smaller"></small></p></aside>').prependTo($footer);
      
      return $('.js-lastfm', $footer);
    }
    
    function getContext() {
      var $context = $('.js-lastfm');
      
      $context = $context.length ? $context : setContext();
      
      return $context;
    }
    
    function updateAlbumCover() {
    }
    
    var $container = getContext();
    
    if (track) {
      var $cover = $('<img class="js-lastfm__cover" src="' + track.cover[0]['#text'] + '" alt="Jaquette de l\'album ' + track.album + '." />');
      $container.text(" Écoute actuellement : " + track.name + " de " + track.artist + ".");
      $cover.prependTo($container);
    } else {
      $container.text("Il est temps de s'accorder un peu de calme.");
    }
  }
  
  $(document).ready(function() {
    var username = 'adrienchretien',
        api = new LastfmAPI('52693228775ec835d6cccc072559fe2e'),
        np = new NowPlaying(api, username, displayTrack, 45);
    
    np.autoUpdate();
  });
})(document);