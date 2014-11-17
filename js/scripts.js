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

NowPlaying = function(api, user, success, error, interval) {
    this.api = api;
    this.user = user;
    this.success = success;
    this.error = error || function(error) { console && console.log(error); };
    
    /* AutoUpdate frequency - Last.fm API rate limits at 1/sec */
    this.interval = interval || 5;
};
NowPlaying.prototype = {
    
    update: function()
    {
        this.api.getNowPlayingTrack(
            this.user,
            jQuery.proxy(this.handleNowPlayingTrackResponse, this), 
            this.error
        );
    },
  
    updateAlbum: function (mbid, track)
    {
        this.api.getAlbumInfo(
            mbid,
            jQuery.proxy(this.handleAlbumInfoResponse, this, track),
            this.error
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
                album: response.album['#text']
            };
                
            this.updateAlbum(response.album.mbid, track);
        }
    },
  
    handleAlbumInfoResponse: function(track, response) {
        if (response) {
            track.cover = response.image;
          
            this.success(track);
        }
        else {
            this.success(null);
        }
    }
      
};

/** Personnal script */

(function (document) {
  var WidgetLastFm = function(track) {
    var $aside = null,
        $widget = null;
    
    function updateHtml(track) {
      var newHtml = '<img class="js-lastfm__cover" ' + 
                    'src="' + track.cover[1]['#text'] + '" ' +
                    'alt="Jaquette de l\'album ' + track.album + '." />' +
                    '<div class="js-lastfm__details">' +
                      '<span class="js-lastfm__title">Écoute actuellement : </span>' +
                      '<p class="js-lastfm__work">' +
                        '<cite>' + track.name + '</cite> de ' + track.artist + '.' +
                      '</p>' +
                    '</div>';
      var oldHtml = $widget.html();
      
      if (oldHtml != newHtml) {
        $widget.html(newHtml);
      }
    }
    
    function update(track) {
      if (track) {
        updateHtml(track);
        $widget.show();
      } else {
        hide();
      }
    }
    
    function handleAPIError(error) {
      // Uncomment that line for debug.
      // console && console.log(error);
      
      $widget.hide();
    }
    
    // Widget initialization    
    $aside = $('.p-footer aside');
    $widget = $('.js-lastfm', $aside);

    if ($widget.length === 0) {
      $widget = $('<div class="js-lastfm"></div>');
      $widget.hide();
      $widget.appendTo($aside);
    }
    
    return {
      update: update,
      handleAPIError: handleAPIError
    }
  };
  
  $(document).ready(function() {
    var username = 'adrienchretien',
        widget = new WidgetLastFm(),
        api = new LastfmAPI('52693228775ec835d6cccc072559fe2e'),
        np = new NowPlaying(api, username, widget.update, widget.handleAPIError, 45);
    
    np.autoUpdate();
  });
})(document);
