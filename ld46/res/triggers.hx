{
  // Larva
  base: function() {
    return humanity >= 50;
  },

  // Urchin
  good: function() {
    return humanity >= 75 ||
          (humanity > 50 && (veggies > 5 && cloth > 5));
  },

  // Hound
  bad: function() {
    return humanity > 35 ||
          (humanity > 25 && (meat > 5 && armor > 5));
  },

  // Mimic
  good2: function() {
    return humanity > 75;
  },

  // Brute
  neutral: function() {
    return humanity > 50;
  },

  // Beast
  bad2: function() {
    return humanity > 25;
  }
};