//
//  WalletListCell.m
//  hero-ios
//
//  Created by 李潇 on 2018/11/15.
//

#import "WalletListCell.h"
#import "UIView+Hero.h"
#import "UIView+Addition.h"

@interface WalletListCell ()

@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *addressLabel;
@property (nonatomic) UIImageView *logoView;

@end

@implementation WalletListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"hero-ios" withExtension:@"bundle"]];
    UIImage *logo = [UIImage imageNamed:@"avatar" inBundle:bundle compatibleWithTraitCollection:nil];
    _logoView = [[UIImageView alloc] initWithImage:logo];
    _logoView.frame = CGRectMake(21, 13, 64, 64);
    _logoView.clipsToBounds = YES;
    _logoView.layer.cornerRadius = 32;
    [self.contentView addSubview:_logoView];
    
    _nameLabel = [UILabel new];
    _nameLabel.textColor = UIColorFromRGB(0x333333);
    _nameLabel.frame = CGRectMake(99, 24, SCREEN_W-99-33, 21);
    _nameLabel.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:_nameLabel];
    
    _addressLabel = [UILabel new];
    _addressLabel.textColor = UIColorFromRGB(0x999999);
    _addressLabel.frame = CGRectMake(99, 50, SCREEN_W-99-87, 21);
    _addressLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _addressLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_addressLabel];
    
    UIView *line = [UIView new];
    line.backgroundColor = UIColorFromRGB(0xe2e2e2);
    line.frame = CGRectMake(21, 89, SCREEN_W-21*2, 1);
    [self.contentView addSubview:line];
}

- (void)setAccount:(HeroAccount *)account {
    self.nameLabel.text = account.name;
    self.addressLabel.text = account.address;
}

@end
