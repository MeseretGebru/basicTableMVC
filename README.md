# basicTableMVC

Back to basics! 

This project is intended as a very bare-bones example of a tableview that loads information into cells from a remote API.

Most of my projects use tableviews, of course, but they aren't good to use as examples for beginners because they often include distracting code that implements custom UI or button actions.

![A screenshot of the app, displaying a list of tarot cards and their accompanying card faces, running on an iPhone 5s][screenshot-1-table]

This tableview uses the same server-side Swift API featured in the [tarotReader project][link-tarot-reader]. It is more or less the same as the tarotReader in terms of the API calls, the only difference being that the cards are presented in table cells instead of UIViews.

## Basic Structure

Well, if you look at the bundle, you've got 4 main groups: Models, Views, Controllers, and an extra group that breaks the MVC pattern -- Networking.

![A screenshot of the app's bundle, displaying all the files in a table of contents like heirarchy][screenshot-2-bundle]

### Models

Models contains only one file: a tarot card class. Note that the class inherits from Codable, but it still does the JSON parsing the Swift3 way, to illustrate.

The three properties on the card class are title, description, and imageAddress. 

TarotCard comes with a failable convenience initializer that accepts a dictionary of [String : Any]. If we can't find the right keys or the image field can't be converted to a URL, this init fails and gives us nil.

The card's image is stored in here as a URL, rather than as a String or a UIImage. This ensures that we get a properly formatted URL, while holding off on storing a big graphical file inside the object, which saves a little on memory and on the amount of time it takes to set up the object. We wait until we need the image to be displayed, then we grab it.

![A screenshot of the complete model class code][screenshot-3-model]

### Views

Views contains our storyboards and the assets folder. We do use the Main storyboard, but the Launch Screen storyboard and image assets are both currently empty.

![A screenshot of the only view controller in the app displayed on the storyboard][screenshot-4-storyboard]

### Controllers

Controllers contains our only controller. It is a UITableViewController, naturally. It contains an extension that holds three methods, which handle our API calls. 

Why an extension, rather than putting them right in the class? I think it's more readable. It's also easier to pull the extension out into its own file, so you can look at the bundle and see where the API call methods are happening, rather than digging around through a single lengthy view controller file. 

The first method in our extension uses our API manager to retrieve cards. It is what you would call a wrapper for the API call. Wrappers make code easier to read, because instead of writing out the whole API call inside of viewDidLoad, we just need to type in self.grabThisMany(cards: 23).

The second method in our extension is a method that actually goes in, looks at the JSON, and reports if it encountered an error or made a card. It is the longest method in the project because it has numerous catch blocks for error handling inside the JSON. This is our API manager's callback.

The third method retrieves the card images and does not use our API manager at all. You don't need to use an API manager to do networking -- but having it can simplify complex operations, like deserializing JSON, initializing cards, and adding them to a tableview datasource. The third method is fairly simple in operation, so it doesn't need all that.

The API call for the cards happens in viewDidLoad, whereas the API call for the images happens later, inside the tableview method cellForRowAtIndexPath.

![A screenshot of the controller's viewDidLoad][screenshot-5-controller]

### Networking

Networking contains the API manager, its endpoint, and an enum we'll use for special API errors.

Instead of a singleton, we make an instance of the manager inside our only view controller, and use that to make API calls. We stash the stuff we get from our API calls inside an array we make inside of our view controller. We make a call to get our cards one URL at a time, via a loop. 

Our manager does one weird thing, in that, inside the class definition, you will see a queue that blocks the thread temporarily to ensure we don't have a [data race][link-data-race] as cards come in and get added to the array. The queue is set to fileprivate, meaning it can only be used within the API manager file's scope. Other classes can't use it, and other parts of the app can't call it.

The endpoint is contained in its own file, as a static property on a struct. This is because Strings are inherently messy. If you have something like an endpoint, where it's text but it represents a value that you need to get right to ensure that the app runs correctly, you should store the text inside a struct or an enum. This makes it easier to change later, and also prevents you from making a typo and destroying your app.

Errors are also enums. This simplifies writing the do-catch block in the callback inside our controller.

![A screenshot of the API manager class in full, including the queue][screenshot-6-networking]

### P-list

Because the site the calls are making hits to isn't https, we set up our app to allow arbitrary loads. This isn't great for security, but it is sometimes necessary. You can add this functionality by hovering over the Information Property List key, clicking on the little plus sign, and typing into the fields that come up.

![A screenshot of the p-list, displaying the Allow Arbitrary Loads field][screenshot-7-plist]

----

This isn't the only way to do things, obviously, or even, necessarily, the best way, but it is the most representative of the various ways I've made API calls to fill up a table. It's hard to be absolutely basic, so even this includes some oddities, like the custom queue. 

What can I say? APIs are like snowflakes. Every one of them is different. They all present with unique challenges, and the real trick is figuring out what to generalize so you can handle whatever the API throws at you.

[link-tarot-reader]: https://github.com/martyav/tarotReader
[link-data-race]: https://stackoverflow.com/a/34550
[screenshot-1-table]: http://i64.tinypic.com/10nhpi1.png
[screenshot-2-bundle]: http://i64.tinypic.com/118zpkn.png
[screenshot-3-model]: http://i63.tinypic.com/a48pwl.png
[screenshot-4-storyboard]: http://i68.tinypic.com/2mga0cp.png
[screenshot-5-controller]: http://i67.tinypic.com/2uysuo5.png
[screenshot-6-networking]: http://i64.tinypic.com/6s8m0x.png
[screenshot-7-plist]: http://i63.tinypic.com/2vjq138.png
