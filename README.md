# Link Developer SDK for iOS

Provides an Objective C interface to the "Link" service by HP for creating watermarked images, QR codes, and mobile-friendly shortened URLs.

## Installation via Cocoapods

Add the Link Developer SDK to your Podfile:

```
pod 'LivePaperSDK'
```

## Manual installation

To manually include the Link Developer SDK for iOS, do the following:

* Clone the SDK from github - [https://github.com/IPGPTP/live_paper_sdk](https://github.com/IPGPTP/live_paper_sdk).
* Build the LivePaperSDK to generate the framework:
  * Go into the LivePaperSDK folder and run ```pod install```.
  * Open the "LivePaperSDK.xcworkspace" workspace.
  * Select the "LivePaperSDK-Universal" scheme and build it.
  * After the framework is generated, a window will open with the "LivePaperSDK.framework" file.
* Drag the "LivePaperSDK.framework" framework into your Xcode project. When prompted, select "Copy items into destination group’s folder".
* Add a new build phase by clicking the + button > New Copy Files Phase. The new phase will be created at the end of the build phases list.
* In the Copy Files phase you just created, click to open the detail disclosure arrow and configure as follows:
  * Destination : Frameworks
  * Click the + button under the list, and find the LivePaperSDK.framework in the modal window that appears; click Add
  * Check Code Sign On Copy
* When releasing, in the target that will be used to release the app to the App Store, add a new "Run Script" phase with the following content:

```objc
bash "$BUILT_PRODUCTS_DIR/$FRAMEWORKS_FOLDER_PATH/LivePaperSDK.framework/release_strip_archs.sh"
```

# Authenticate

Import `LivePaperSDK.h` at the top of your source file

```objc
#import <LivePaperSDK/LivePaperSDK.h>
```

Then create a new session using your client id and secret.

```objc
LPSession *lpSession = [LPSession createSessionWithClientId:"your client id" secret:"your client secret"];
```

# Quick-Start Usage

## Shortening URLs

To shorten a url, the simplest method is to use the `createShortUrl:destination:completionHandler` method of LPSession.

```objc
NSString *name = @"My Short URL";
NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
[lpSession createShortUrl:name destination:url completionHandler:^(NSURL *shortUrl, NSError *error) {
  if (shortUrl) {
    [self showAlert:@"Created ShortURL" message:[shortUrl absoluteString]];
  } else {
    [self showAlert:@"Error" message:[error description]];
  }
}];
```

## Generating QR Codes

To create a QR Code, the simplest method is to use the `createQrCode:destination:completionHandler` method of LPSession.
Specify the URL that the QR Code should take you to when scanned.

```objc
NSString *name = @"My QR Code";
NSURL *url = [NSURL URLWithString:@"https://www.amazon.com"];
[lpSession createQrCode:name destination:url completionHandler:^(UIImage *image, NSError *error) {
  if (image) {
    [self showAlert:@"Created QrCode" image:image];
  } else {
    [self showAlert:@"Error" message:[error description]];
  }
}];
```

Currently, the Link Developer SDK only returns QR Code images in jpg format.</div>

## Watermarking Images

To watermark an image, the quickest method is to use the `createWatermark:destination:imageURL:completionHandler` method of LPSession.
Specify the URL to the JPEG image to be watermarked, and the URL that the watermarked image should take you to when scanned.

```objc
NSString *name = @"My Watermark";
NSURL *url = [NSURL URLWithString:@"https://www.hp.com"];
NSURL *imageURL = [NSURL URLWithString:@"https://s3-us-west-1.amazonaws.com/linkcreationstudio.com/developer/zion_600x450.jpg"];
[lpSession createWatermark:name destination:url imageURL:imageURL completionHandler:^(UIImage *watermarkedImage, NSError *error) {
  if (watermarkedImage) {
    [self showAlert:@"Watermarked Image" image:watermarkedImage];
  } else {
    [self showAlert:@"Error" message:[error description]];
  }
}];
```

Currently, the Link Developer SDK only returns watermarked images in jpg format.</div>

## Watermarking Images with Rich Payoff
To watermark an image that goes to an interactive mobile experience, use the `createWatermark:richPayoffData:publicURL:imageURL:completionHandler` method of LPSession.
Specify the URL to the JPEG image to be watermarked, and the rich payoff data that the watermarked image should show when scanned.

```objc
NSString *name = @"My Watermark With Rich Payoff";
NSURL *url = [NSURL URLWithString:@"https://www.hp.com"];
NSURL *imageURL = [NSURL URLWithString:@"http://static.movember.com/uploads/2014/profiles/ef4/ef48a53fb031669fe86e741164d56972-546b9b5c56e15-hero.jpg"];
NSDictionary *richPayoffData = @{
  @"type" : @"content action layout",
  @"version" : @"1",
  @"data" : @{
    @"content" : @{
      @"type" : @"image",
      @"label" : @"Movember!",
      @"data" : @{
        @"URL" : @"http://static.movember.com/uploads/2014/profiles/ef4/ef48a53fb031669fe86e741164d56972-546b9b5c56e15-hero.jpg"
      }
    },
    @"actions" : @[
      @{
        @"type" : @"webpage",
        @"label" : @"Donate!",
        @"icon" : @{ @"id" : @"533" },
        @"data" : @{ @"URL" : @"http://MOBRO.CO/oamike" }
      },
      @{
        @"type" : @"share",
        @"label" : @"Share!",
        @"icon" : @{ @"id" : @"527" },
        @"data" : @{ @"URL" : @"Help Mike get the prize of most donations on his team! MOBRO.CO/oamike"}
      }
    ]
  }
};
[lpSession createWatermark:name richPayoffData:richPayoffData publicURL:url imageURL:imageURL completionHandler:^(UIImage *watermarkedImage, NSError *error) {
  if (watermarkedImage) {
    [self showAlert:@"Watermarked Image" image:watermarkedImage];
  } else {
    [self showAlert:@"Error" message:[error description]];
  }
}];
```

# Usage

The Link Developer SDK for iOS supports the full set of CRUD operations on the underlying objects.  If you
do not need to update or delete previously created objects, see the quick-start section above.

## Underlying Objects

**Triggers** represent the object you want to put on a page: a short url, QR code, or watermarked image.
**Payoffs** are destinations, either the url of a webpage, or an interactive mobile experience.
**Links** join a Trigger to a Payoff.
**Projects** represent an entity in which you create Triggers, Payoffs and Links.

## CRUD Example

```objc
NSString *name = @"ShortURL Example";
NSString *projectId = @"project id";
NSURL *url = [NSURL URLWithString:@"https://www.hp.com"];
LPSession *lpSession = [LPSession createSessionWithClientId:@"your client id" secret:@"your client secret"];
[LPTrigger createShortUrlWithName:name projectId:projectId session:lpSession completion:^(LPTrigger *trigger, NSError *error) {
  if (trigger) {
    [LPPayoff createWebPayoffWithName:name url:url projectId:projectId session:lpSession completion:^(LPPayoff *payoff, NSError *error) {
      if (payoff) {
        [LPLink createWithName:name triggerId:trigger.identifier payoffId:payoff.identifier projectId:projectId session:lpSession completion:^(LPLink *link, NSError *error) {
          if (link) {
            trigger.shortURL; // returns url of the form http://hpgo.co/abc123
          }
        }];
      }
    }];
  }
}];
```

After creating, you will need to persist the link, payoff, and trigger IDs in some form of
permanent storage to later access the resources.

If you want to change the destination:

```objc
LPSession *lpSession = [LPSession createSessionWithClientId:@"your client id" secret:@"your client secret"];
NSString *payoffId = @"payoff id";
NSString *projectId = @"project id";
[LPPayoff get:payoffId projectId:projectId session:lpSession completion:^(LPPayoff *payoff, NSError *error) {
  if (payoff) {
    payoff.url = [NSURL URLWithString:@"http://shopping.hp.com"];
    [payoff update:^(NSError *error) {
      if (!error) {
        payoff.url // returns the new URL
      }
    }];
  }
}];
```

Still later, if you wanted to delete the resources, do the following
(deleting the link first to avoid resource conflict):

```objc
NSString *projectId = @"project id";
NSString *linkId = @"Link Id";
LPSession *lpSession = [LPSession createSessionWithClientId:@"your client id" secret:@"your client secret"];

// delete link first, to avoid resource conflict
[LPLink get:linkId projectId:projectId session:lpSession completion:^(LPLink *link, NSError *error) {
    if (link) {
        [link delete:^(NSError *error) {
            if (!error) {
                // delete trigger
                [LPTrigger get:link.triggerId projectId:projectId session:lpSession completion:^(LPTrigger * _Nullable trigger, NSError * _Nullable error) {
                    if (trigger) {
                        [trigger delete:^(NSError *error) {}];
                    }
                }];

                // delete payoff
                [LPPayoff get:link.payoffId projectId:projectId session:lpSession completion:^(LPPayoff *payoff, NSError *error) {
                    if (payoff) {
                        [payoff delete:^(NSError *error) {}];
                    }
                }];
            }
        }];
    }
}];
```

You can list existing resources with the list operation.

```objc
NSString *projectId = @"project id";
LPSession *lpSession = [LPSession createSessionWithClientId:@"your client id" secret:@"your client secret"];
[LPLink list:lpSession projectId:projectId completion:^(NSArray<LPLink *> *links, NSError *error) {
    links; // returns array of LPLink objects
}];
[LPPayoff list:lpSession projectId:projectId completion:^(NSArray<LPPayoff *> *payoffs, NSError *error) {
    payoffs; // returns array of LPPayoff objects
}];
[LPTrigger list:lpSession projectId:projectId completion:^(NSArray *triggers, NSError *error) {
    triggers; // returns array of LPTrigger objects
}];
```

## QR Code Example

```objc
NSString *projectId = @"project id";
NSString *name = @"QRCode Example";
NSURL *url = [NSURL URLWithString:@"http://www.hp.com"];
LPSession *lpSession = [LPSession createSessionWithClientId:@"your client id" secret:@"your client secret"];
[LPTrigger createQrCodeWithName:name projectId:projectId session:lpSession completion:^(LPTrigger * _Nullable trigger, NSError * _Nullable error) {
    if (trigger) {
        [LPPayoff createWebPayoffWithName:name url:url projectId:projectId session:lpSession completion:^(LPPayoff *payoff, NSError *error) {
            if (payoff) {
                [LPLink createWithName:name triggerId:trigger.identifier payoffId:payoff.identifier projectId:projectId session:lpSession completion:^(LPLink *link, NSError *error) {
                    if (link) {
                        [trigger getQrCodeImageWithProgress:^(double progress) {
                            // Progress
                        } completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
                            image; // returns QR Code image
                        }];
                    }
                }];
            }
        }];
    }
}];
```

## Watermarked Image Example

```objc
NSString *projectId = @"project id";
NSString *name = @"Watermark Example";
UIImage *image = [UIImage imageNamed:@"image_to_watermark"];
NSData *imageData = UIImageJPEGRepresentation(image, 0.95);
NSURL *url = [NSURL URLWithString:@"http://www.hp.com"];
LPSession *lpSession = [LPSession createSessionWithClientId:@"your client id" secret:@"your client secret"];
[LPTrigger createWatermarkWithName:name projectId:projectId session:lpSession completion:^(LPTrigger * _Nullable trigger, NSError * _Nullable error) {
    if (trigger) {
        [LPPayoff createWebPayoffWithName:name url:url projectId:projectId session:lpSession completion:^(LPPayoff *payoff, NSError *error) {
            if (payoff) {
                [LPLink createWithName:name triggerId:trigger.identifier payoffId:payoff.identifier projectId:projectId session:lpSession completion:^(LPLink *link, NSError *error) {
                    if (link) {
                        // Download watermark image
                        [trigger getWatermarkForImageData:imageData strength:10 watermarkResolution:50 imageResolution:120 adjustImageLevels:YES progress:^(double progress) {
                            // Progress
                        } completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
                            if (image) {
                                image; // returns Watermark image
                            }
                        }];
                    }
                }];
            }
        }];
    }
}];
```

# Sample App

You can also look at the LivePaperSample app included in the SDK. This app demonstrates how to use the __LivePaper SDK for iOS__.
Before running the app, enter your credentials in the ProjectsTableViewController file located at LivePaperSDK/LivePaperSample/Controllers/ProjectsTableViewController.swift:

```
let LPP_CLIENT_ID = "CLIENT_ID_HERE"
let LPP_CLIENT_SECRET = "CLIENT_SECRET_HERE"
```
