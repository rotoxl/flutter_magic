# Magic API &amp; Flutter


* data is fetched from [Magic API](https://docs.magicthegathering.io/) at startup
* details page is composed of 4-5 configurable blocks (you may choose the attributes to render in each block)

![List](screenshots/list.png)
![Details](screenshots/detail.png)

# Next steps
* startup
	* choose last used EndPoint
* analytics
* cupertino style?
* detail window
	* related items widget
* list page
	* dropdown menu to access last 4 APIs??
	* search 
* change API endpoint window
	* add more (bundled) API endpoints
		* https://www.googleapis.com/books/v1/volumes?q=reilly
		* Planets API
	* "add new endpoint" logic & form
* detailconfig window
	* new chips, stats widgets, new fields are still not configurable

# Recently added
* "about this API" dialog
* icon, splash & startup
* list page
	* toggle view list/grid
* config/change API screen
	* "change endpoint" to choose from a list of bundled & user API endpoints (recently used first)
	* show color/change color 
* detail window
	* open main image
	* images widget
	* rebuild to be closer to [this](https://d33wubrfki0l68.cloudfront.net/4ac7d7e147f5505b66e74ce6698193a58f796776/67682/images/from-wireframes-to-flutter-movie-details-page/movie_details_ui_result.png)



