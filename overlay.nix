self: super:
{
  mutate = self.callPackage ./mutate { };
  gitconfig = self.callPackage ./gitconfig { };
}

