//
//  BBChooserViewController.m
//  BloodBot
//
//  Created by Lee Danilek on 5/31/14.
//  Copyright (c) 2014 Ship Shape. All rights reserved.
//

#import "BBChooserViewController.h"

#import "BBObject.h"

@interface BBChooserViewController () <UIScrollViewDelegate>

@property BOOL laidOut;

@end

@implementation BBChooserViewController

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int choice = (scrollView.contentOffset.x+5)/scrollView.bounds.size.width;
    NSString *d; NSString *img;
    NSString *name = [self nameForChoice:choice description:&d imageName:&img];
    [self.delegate chooser:self chose:choice named:name];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)nameForChoice:(int)choice description:(NSString **)description imageName:(NSString **)imageName {
    NSString *name;
    switch (self.chooserType) {
        case BBPersonChooser:
        {
            switch ((BBPerson)choice) {
                case BBPersonAverage:
                    name=@"Sue";
                    *description=@"Sue is a female human with average blood.";
                    break;
                    
                case BBPersonSickle:
                    name=@"Larry";
                    *description=@"Larry is young male with Sickle-cell anemia. His shrivelled red blood cells carry less oxygen, but make him resistant to HIV and Malaria.";
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case BBPathogenChooser:
        {
            switch ((BBPathogenType)choice) {
                case BBPathogenTB:
                    name=@"Tuberculosis";
                    //http://www.buzzle.com/articles/bacterial-blood-infection.html
                    //from wikipedia and cdc.gov/tb
                    *description=@"TB spreads through the air and has a tendency to become resistant to treatment. This bacteria usually infects the lungs but can also attack the brain or other organs.";
                    break;
                    
                case BBPathogenHIV:
                    name=@"HIV";
                    *description = @"Human Immunodeficiency Virus causes Acquired ImmunoDeficiency Syndrome (AIDS). The virus corrupts white blood cells to reproduce.";
                    break;
                    
                case BBPathogenMalaria:
                    name=@"Malaria";
                    *description = @"Spread by mosquitos, the protozoans which cause Malaria reproduce in the red blood cells.";
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case BBLocationChooser:
        {
            switch ((BBLocation)choice) {
                    
                case BBLocationPulmonaryArtery:
                    name=@"Pulmonary Artery";
                    *description = @"Deoxygenated blood straight from the heart's right ventricle travels through the pulmonary vein to the lungs.";
                    break;
                    
                case BBLocationPulmonaryVein:
                    name=@"Pulmonary Vein";
                    *description = @"Freshly oxygenated blood moves from the lungs, through the pulmonary artery, to the left atrium of the heart.";
                    break;
                    
                case BBLocationCarotidArtery:
                    name=@"Carotid Artery";
                    *description = @"The carotid arteries carry oxygenated blood to the brain.";
                    break;
                    
                case BBLocationVenaCava:
                    name=@"Vena Cava";
                    *description = @"After blood has circulated around the body, it returns to the heart through the vena cava. This blood is slow, under low pressure, and deoxygenated.";
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    return name;
}

- (UIView *)viewForChoice:(int)choice {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(choice*self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    NSString *description;
    NSString *imageName;
    NSString *name = [self nameForChoice:choice description:&description imageName:&imageName];
    CGSize LABEL_SIZE = CGSizeMake(200, 50);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(view.bounds.size.width/2-LABEL_SIZE.width/2, 30, LABEL_SIZE.width, LABEL_SIZE.height)];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=name;
    [view addSubview:label];
    CGSize DESCRIPTION_SIZE = CGSizeMake(view.bounds.size.width-40, 300);
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(view.bounds.size.width/2-DESCRIPTION_SIZE.width/2, 100, DESCRIPTION_SIZE.width, DESCRIPTION_SIZE.height)];
    textView.editable=NO;
    textView.text=description;
    [view addSubview:textView];
    return view;
}

- (int)choiceCount {
    switch (self.chooserType) {
        case BBLocationChooser:
            return LOCATIONS;
            break;
            
            case BBPathogenChooser:
            return PATHOGENS;
            break;
            
            case BBPersonChooser:
            return PEOPLE;
            break;
            
        default:
            return 0;
            break;
    }
    return 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    if (!self.laidOut) {
        self.laidOut=YES;
        for (int i=0; i<[self choiceCount]; i++) {
            [self.scrollView addSubview:[self viewForChoice:i]];
        }
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*[self choiceCount], self.view.bounds.size.height);
        self.scrollView.pagingEnabled=YES;
        [self.scrollView scrollRectToVisible:CGRectMake(self.currentChoice*self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height) animated:NO];
        self.scrollView.delegate=self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
