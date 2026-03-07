import { useMemo } from 'react';
import {
  Image,
  ImageSourcePropType,
  StyleSheet,
  Text,
  View,
  useWindowDimensions
} from 'react-native';

type Props = {
  logoSource: ImageSourcePropType;
};

type DecoItem = {
  id: string;
  text: string;
  color: string;
  top: string;
  left: string;
  size: number;
  rotate: string;
  opacity: number;
};

const FORMULAS = [
  'E = mc²',
  'πr²',
  'F = ma',
  'a² + b² = c²',
  'V = I · R',
  'Δx/Δt',
  '∫ f(x)dx',
  'x² + y² = z²',
  'Σ(a+b)',
  'A = πr²',
  'P = 2(a+b)',
  'm/v'
];

const ROCKETS = ['🚀', '🛰️', '🚀', '🚀', '🛸'];
const MECHANICS = ['⚙️', '🔩', '🔧', '🛠️', '⛓️', '⚙️'];

const FORMULA_COLORS = ['#F97316', '#2563EB', '#16A34A', '#E11D48', '#9333EA', '#14B8A6'];
const MECH_COLORS = ['#0F766E', '#374151', '#0369A1', '#4B5563'];

function randInt(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randomFrom<T>(items: T[]) {
  return items[randInt(0, items.length - 1)];
}

function createItems(
  kind: 'formula' | 'rocket' | 'mechanic',
  count: number,
  _width: number,
  _height: number
): DecoItem[] {
  const source = kind === 'formula' ? FORMULAS : kind === 'rocket' ? ROCKETS : MECHANICS;

  return Array.from({ length: count }, (_, index) => {
    const top = `${randInt(4, 92)}%`;
    const left = `${randInt(3, 92)}%`;
    const rotate = `${randInt(-30, 30)}deg`;

    const size =
      kind === 'formula' ? randInt(16, 28) : kind === 'rocket' ? randInt(22, 36) : randInt(22, 34);

    const color =
      kind === 'formula'
        ? randomFrom(FORMULA_COLORS)
        : kind === 'mechanic'
          ? randomFrom(MECH_COLORS)
          : '#1D4ED8';

    const opacity = kind === 'formula' ? 0.88 : kind === 'rocket' ? 0.9 : 0.85;

    return {
      id: `${kind}-${index}`,
      text: randomFrom(source),
      color,
      top,
      left,
      size,
      rotate,
      opacity
    };
  });
}

export function RandomSTEMBackground({ logoSource }: Props) {
  const { width, height } = useWindowDimensions();

  const formulas = useMemo(() => createItems('formula', 12, width, height), [width, height]);
  const rockets = useMemo(() => createItems('rocket', 8, width, height), [width, height]);
  const mechanics = useMemo(() => createItems('mechanic', 10, width, height), [width, height]);

  return (
    <View style={styles.backgroundLayer} pointerEvents="none">
      <Image source={logoSource} style={styles.backgroundLogoFull} resizeMode="cover" />
      <Image source={logoSource} style={styles.backgroundLogoOverlay} resizeMode="contain" />

      {formulas.map((item) => (
        <Text
          key={item.id}
          style={[
            styles.bgItem,
            {
              color: item.color,
              fontSize: item.size,
              left: item.left,
              opacity: item.opacity,
              top: item.top,
              transform: [{ rotate: item.rotate }]
            }
          ]}
        >
          {item.text}
        </Text>
      ))}

      {rockets.map((item) => (
        <Text
          key={item.id}
          style={[
            styles.bgItem,
            {
              color: item.color,
              fontSize: item.size,
              left: item.left,
              opacity: item.opacity,
              top: item.top,
              transform: [{ rotate: item.rotate }]
            }
          ]}
        >
          {item.text}
        </Text>
      ))}

      {mechanics.map((item) => (
        <Text
          key={item.id}
          style={[
            styles.bgItem,
            {
              color: item.color,
              fontSize: item.size,
              left: item.left,
              opacity: item.opacity,
              top: item.top,
              transform: [{ rotate: item.rotate }]
            }
          ]}
        >
          {item.text}
        </Text>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  backgroundLayer: {
    ...StyleSheet.absoluteFillObject,
    overflow: 'hidden'
  },
  backgroundLogoFull: {
    ...StyleSheet.absoluteFillObject,
    opacity: 0.07
  },
  backgroundLogoOverlay: {
    height: 700,
    left: '-10%',
    opacity: 0.08,
    position: 'absolute',
    top: '8%',
    width: 700
  },
  bgItem: {
    fontWeight: '800',
    position: 'absolute'
  }
});
