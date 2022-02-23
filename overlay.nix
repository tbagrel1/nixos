self: super:
{
  mutate = self.callPackage ./mutate { };
  gitconfig = self.callPackage ./gitconfig { };
  nixconfig = self.callPackage ./nixconfig { };
  stackconfig = self.callPackage ./stackconfig { };
  actkbdconfig = self.callPackage ./actkbdconfig { };
}

